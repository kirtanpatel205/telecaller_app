import 'dart:async';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:get/get.dart';
import 'package:collection/collection.dart';
import 'package:telecaller_app/core/controllers/overlay_controller.dart';
import 'package:telecaller_app/core/models/all_lead_entity.dart';
import 'package:telecaller_app/core/models/lead_contact_id_entity.dart';
import 'package:telecaller_app/core/services/api_service.dart';
import 'package:telecaller_app/core/services/phone_status_service.dart';

class AutoDialerController extends GetxController {
  late final ApiService _apiService;

  // ─────────────────────────────────────────────
  // STATUS / STATS
  // ─────────────────────────────────────────────
  final status = 'idle'.obs;
  final isLoading = false.obs;

  final totalAttempts = 0.obs;
  final connected = 0.obs;
  final successful = 0.obs;
  final failed = 0.obs;

  // ─────────────────────────────────────────────
  // CALL TIMER
  // ─────────────────────────────────────────────
  final callTimer = '00:00'.obs;
  Timer? _activeCallTimer;
  int _seconds = 0;

  // ─────────────────────────────────────────────
  // PAGEWISE — LEADS
  // ─────────────────────────────────────────────
  final totalLeads = 0.obs;
  late PagewiseLoadController<AllLeadLeads> pagewiseLeadsController;

  /// Flat accumulated list shown in the dropdown.
  final leadsDropdownList = <AllLeadLeads>[].obs;
  final isLeadsLoadingMore = false.obs;

  bool get hasMoreLeads => leadsDropdownList.length < totalLeads.value;

  // Currently selected lead dataset
  final selectedLeadDataset = Rxn<AllLeadLeads>();

  // ─────────────────────────────────────────────
  // PAGEWISE — CONTACTS (per selected lead)
  // ─────────────────────────────────────────────
  final totalContacts = 0.obs;
  PagewiseLoadController<LeadContactIdLeadContacts>? pagewiseContactsController;

  // Flat list kept in sync for the auto-dialer queue builder
  final contactQueue = <LeadContactIdLeadContacts>[].obs;

  // ─────────────────────────────────────────────
  // DIALER SETTINGS
  // ─────────────────────────────────────────────
  final autoNextLead = true.obs;
  final callSpeed = 3.0.obs;

  // Current displayed contact
  final currentContact = Rxn<LeadContactIdLeadContacts>();
  final countdown = 0.obs;

  // ─────────────────────────────────────────────
  // LIFECYCLE
  // ─────────────────────────────────────────────

  /// When coming from the Leads page with an id argument, auto-select that lead.
  String? _pendingIncomingLeadId;

  @override
  void onInit() {
    super.onInit();
    _apiService = Get.find<ApiService>();

    // Stash incoming argument — used during first-page fetch below
    if (Get.arguments != null && Get.arguments['id'] != null) {
      _pendingIncomingLeadId = Get.arguments['id'] as String?;
    }

    _initLeadsPagewise();

    // ✅ Directly trigger the first API call to populate the dropdown list.
    // (pageFuture only fires when consumed by a PagewiseSliverList/PagewiseListView,
    //  which no longer exists for leads — we use a dropdown instead.)
    _fetchFirstLeadsPage();

    // Listen to call status for active timer
    final phoneService = Get.find<PhoneStatusService>();
    ever(phoneService.isCallActive, (bool active) {
      if (active) {
        _startActiveTimer();
        if (status.value == 'idle') status.value = 'dialing';
      } else {
        _stopActiveTimer();
        if (status.value == 'dialing') status.value = 'idle';
      }
    });
  }

  @override
  void onClose() {
    _stopActiveTimer();
    pagewiseContactsController?.dispose();
    super.onClose();
  }

  // ─────────────────────────────────────────────
  // PAGEWISE INIT — LEADS
  // ─────────────────────────────────────────────
  void _initLeadsPagewise() {
    leadsDropdownList.clear();
    pagewiseLeadsController = PagewiseLoadController<AllLeadLeads>(
      pageSize: 10,
      pageFuture: (pageNumber) async {
        try {
          final response = await _apiService.allLead(
            page: pageNumber ?? 0,
            limit: 10,
          );
          if (response.status ?? false) {
            totalLeads.value = response.total ?? 0;
            final leads = response.leads ?? [];

            // Accumulate into flat dropdown list (avoid duplicates)
            final existing = leadsDropdownList.map((e) => e.id).toSet();
            final fresh = leads.where((l) => !existing.contains(l.id)).toList();
            leadsDropdownList.addAll(fresh);

            // Auto-select lead when navigated from another page with an id argument
            if (pageNumber == 0 &&
                _pendingIncomingLeadId != null &&
                selectedLeadDataset.value == null) {
              final match = leads.firstWhereOrNull(
                (d) => d.id == _pendingIncomingLeadId,
              );
              if (match != null) {
                Future.microtask(() => onLeadSelected(match));
                _pendingIncomingLeadId = null;
              }
            }

            return leads;
          }
          return [];
        } catch (e) {
          print('❌ Leads pagewise error: $e');
          rethrow;
        }
      },
    );
  }

  /// Fetch page 0 directly — called from onInit and resetLeads.
  /// Required because pageFuture only fires when consumed by a PagewiseSliverList;
  /// since leads now use a dropdown, we must trigger the fetch manually.
  Future<void> _fetchFirstLeadsPage() async {
    isLoading.value = true;
    try {
      final response = await _apiService.allLead(page: 0, limit: 10);
      if (response.status ?? false) {
        totalLeads.value = response.total ?? 0;
        final leads = response.leads ?? [];

        // Populate dropdown list
        leadsDropdownList.assignAll(leads);

        // Auto-select if navigated here with an id argument
        if (_pendingIncomingLeadId != null && selectedLeadDataset.value == null) {
          final match = leads.firstWhereOrNull(
            (d) => d.id == _pendingIncomingLeadId,
          );
          if (match != null) {
            Future.microtask(() => onLeadSelected(match));
            _pendingIncomingLeadId = null;
          }
        }
      }
    } catch (e) {
      print('❌ _fetchFirstLeadsPage error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load the next page of leads into [leadsDropdownList].
  Future<void> loadMoreLeadsForDropdown() async {
    if (isLeadsLoadingMore.value || !hasMoreLeads) return;
    isLeadsLoadingMore.value = true;
    try {
      final nextPage = (leadsDropdownList.length / 10).floor();
      final response = await _apiService.allLead(page: nextPage, limit: 10);
      if (response.status ?? false) {
        totalLeads.value = response.total ?? 0;
        final leads = response.leads ?? [];
        final existing = leadsDropdownList.map((e) => e.id).toSet();
        final fresh = leads.where((l) => !existing.contains(l.id)).toList();
        leadsDropdownList.addAll(fresh);
      }
    } catch (e) {
      print('❌ loadMoreLeadsForDropdown error: $e');
    } finally {
      isLeadsLoadingMore.value = false;
    }
  }

  /// Call this to reset and re-fetch the leads list (e.g. pull-to-refresh).
  void resetLeads() {
    leadsDropdownList.clear();
    pagewiseLeadsController.reset();
    selectedLeadDataset.value = null;
    contactQueue.clear();
    pagewiseContactsController?.dispose();
    pagewiseContactsController = null;
    totalContacts.value = 0;
    update();
    _fetchFirstLeadsPage(); // re-fetch first page after reset
  }

  // ─────────────────────────────────────────────
  // PAGEWISE INIT — CONTACTS
  // ─────────────────────────────────────────────
  void _initContactsPagewise(String leadId) {
    // Dispose previous controller if any
    pagewiseContactsController?.dispose();
    contactQueue.clear();
    totalContacts.value = 0;

    pagewiseContactsController =
        PagewiseLoadController<LeadContactIdLeadContacts>(
      pageSize: 10,
      pageFuture: (pageNumber) async {
        try {
          final response = await _apiService.getCallLead(
            id: leadId,
            page: pageNumber ?? 0,
            limit: 10,
          );
          if (response.status ?? false) {
            totalContacts.value = response.total ?? 0;
            final items = response.leadContacts ?? [];

            // Keep flat list in sync for startDialing()
            if (pageNumber == 0) {
              contactQueue.assignAll(items);
            } else {
              // Avoid duplicates on refetch
              final existing = contactQueue.map((e) => e.id).toSet();
              final newItems = items.where((i) => !existing.contains(i.id));
              contactQueue.addAll(newItems);
            }

            return items;
          }
          return [];
        } catch (e) {
          print('❌ Contacts pagewise error: $e');
          rethrow;
        }
      },
    );

    update(); // notify GetBuilder/Obx about new controller
  }

  // ─────────────────────────────────────────────
  // LEAD SELECTION
  // ─────────────────────────────────────────────
  void onLeadSelected(AllLeadLeads dataset) {
    selectedLeadDataset.value = dataset;
    if (dataset.id != null && dataset.id!.isNotEmpty) {
      _initContactsPagewise(dataset.id!);
    }
  }

  void clearLeadSelection() {
    selectedLeadDataset.value = null;
    contactQueue.clear();
    pagewiseContactsController?.dispose();
    pagewiseContactsController = null;
    totalContacts.value = 0;
    update();
  }

  // ─────────────────────────────────────────────
  // CALL TIMER
  // ─────────────────────────────────────────────
  void _startActiveTimer() {
    _stopActiveTimer();
    _seconds = 0;
    callTimer.value = '00:00';
    _activeCallTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _seconds++;
      final mins = (_seconds ~/ 60).toString().padLeft(2, '0');
      final secs = (_seconds % 60).toString().padLeft(2, '0');
      callTimer.value = '$mins:$secs';
    });
  }

  void _stopActiveTimer() {
    _activeCallTimer?.cancel();
    _activeCallTimer = null;
  }

  // ─────────────────────────────────────────────
  // AUTO-DIAL START
  // ─────────────────────────────────────────────
  void startDialing() {
    if (contactQueue.isEmpty) {
      Get.snackbar(
        'Error',
        'No contacts available. Please select a Lead dataset first.',
      );
      return;
    }

    status.value = 'dialing';

    if (!Get.isRegistered<OverlayController>()) {
      Get.put(OverlayController());
    }
    final overlayCtrl = Get.find<OverlayController>();

    final queue = contactQueue
        .where((l) => l.contact?.phone != null && l.contact!.phone!.isNotEmpty)
        .map(
          (l) => {
            'id': l.id ?? '',
            'name': l.contact?.name ?? 'Unknown',
            'number': l.contact?.phone ?? '',
          },
        )
        .toList();

    if (queue.isEmpty) {
      Get.snackbar('Error', 'No valid phone numbers found in selected lead.');
      status.value = 'idle';
      return;
    }

    overlayCtrl.callQueue = queue;
    overlayCtrl.currentQueueIndex.value = 1;
    overlayCtrl.isAutoCallMode.value = true;

    _syncWithOverlay(overlayCtrl);

    // Dial first contact
    overlayCtrl.makeDirectCall(queue.first['number']!);
  }

  void _syncWithOverlay(OverlayController overlayCtrl) {
    countdown.bindStream(overlayCtrl.countdown.stream);

    ever(overlayCtrl.isPaused, (bool paused) {
      if (paused) {
        if (status.value == 'dialing') status.value = 'paused';
      } else {
        if (status.value == 'paused') status.value = 'dialing';
      }
    });

    void refreshCurrentContact() {
      final index = overlayCtrl.currentQueueIndex.value;
      final cdValue = overlayCtrl.countdown.value;

      if (cdValue > 0) {
        if (index < overlayCtrl.callQueue.length) {
          final next = overlayCtrl.callQueue[index];
          currentContact.value =
              contactQueue.firstWhereOrNull((l) => l.id == next['id']);
        }
      } else {
        if (index > 0 && index <= overlayCtrl.callQueue.length) {
          final current = overlayCtrl.callQueue[index - 1];
          currentContact.value =
              contactQueue.firstWhereOrNull((l) => l.id == current['id']);
        }
      }
    }

    ever(overlayCtrl.currentQueueIndex, (_) => refreshCurrentContact());
    ever(overlayCtrl.countdown, (_) => refreshCurrentContact());
    refreshCurrentContact();
  }

  // ─────────────────────────────────────────────
  // CONTROLS
  // ─────────────────────────────────────────────
  void pauseDialing() {
    if (status.value == 'dialing') {
      status.value = 'paused';
      if (Get.isRegistered<OverlayController>()) {
        Get.find<OverlayController>().pauseCountdown();
      }
    }
  }

  void stopDialing() {
    status.value = 'idle';
    callTimer.value = '00:00';
    currentContact.value = null;
    if (Get.isRegistered<OverlayController>()) {
      Get.find<OverlayController>().stopCountdown();
    }
  }

  // ─────────────────────────────────────────────
  // MANUAL SINGLE CALL
  // ─────────────────────────────────────────────
  void makeManualCall(LeadContactIdLeadContacts lead) {
    currentContact.value = lead;
    final number = lead.contact?.phone ?? '';
    if (number.isEmpty) return;

    if (!Get.isRegistered<OverlayController>()) {
      Get.put(OverlayController());
    }
    final overlayCtrl = Get.find<OverlayController>();

    overlayCtrl.callQueue = [
      {
        'id': lead.id ?? '',
        'name': lead.contact?.name ?? 'Unknown',
        'number': number,
      },
    ];
    overlayCtrl.currentQueueIndex.value = 0;
    overlayCtrl.isAutoCallMode.value = false;

    overlayCtrl.makeDirectCall(number);
  }
}
