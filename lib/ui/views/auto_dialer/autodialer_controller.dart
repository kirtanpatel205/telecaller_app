import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:get/get.dart';
import 'package:telecaller_app/core/controllers/overlay_controller.dart';
import 'package:telecaller_app/core/models/all_lead_entity.dart';
import 'package:telecaller_app/core/models/lead_contact_id_entity.dart';
import 'package:telecaller_app/core/services/api_service.dart';
import 'package:telecaller_app/core/services/phone_status_service.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final pending = 0.obs;
  final completed = 0.obs;
  final overallTotal = 0.obs;

  double get successRate {
    if (totalAttempts.value == 0) return 0.0;
    return (successful.value / totalAttempts.value) * 100;
  }

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

  // Filtering
  final selectedContactStatus = 'pending'.obs;

  // ─────────────────────────────────────────────
  // DIALER SETTINGS
  // ─────────────────────────────────────────────
  final autoNextLead = true.obs;
  final callSpeed = 3.0.obs;

  // Current displayed contact
  final currentContact = Rxn<LeadContactIdLeadContacts>();
  final nextContact = Rxn<LeadContactIdLeadContacts>();
  final countdown = 0.obs;

  // For expandable list items
  final openedIndex = (-1).obs;

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
        if (status.value != 'dialing') status.value = 'dialing';
      } else {
        _stopActiveTimer();
        // When call ends, we transition to "settled" (overlay showing)
        if (status.value == 'dialing') {
          status.value = 'settled';
        }
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
        if (_pendingIncomingLeadId != null &&
            selectedLeadDataset.value == null) {
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

  /// Refresh only the contacts for the currently selected lead.
  Future<void> refreshContacts() async {
    final lead = selectedLeadDataset.value;
    if (lead != null && lead.id != null) {
      _initContactsPagewise(lead.id!);
      fetchLeadStats();
      // We can wait a bit or return immediately as Pagewise handles its own loading state.
      // But for RefreshIndicator, we might want to wait for the first page.
      await Future.delayed(const Duration(milliseconds: 500)); 
    } else {
      resetLeads();
    }
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
              final statusFilter = selectedContactStatus.value;
              final response = await _apiService.getCallLead(
                id: leadId,
                page: pageNumber ?? 0,
                limit: 10,
                filterBy:
                    statusFilter == 'all' ? null : {"status": statusFilter},
              );
              if (response.status ?? false) {
                totalContacts.value = response.total ?? 0;
                final items = response.leadContacts ?? [];

                  // Keep flat list in sync for startDialing()
                  if (pageNumber == 0) {
                    contactQueue.assignAll(items);
                    
                    // Populate initial current and next if we are idle
                    if (status.value == 'idle' && items.isNotEmpty) {
                      currentContact.value = items[0];
                      if (items.length > 1) {
                        nextContact.value = items[1];
                      }
                    }
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

  void onContactStatusChanged(String statusValue) {
    if (selectedContactStatus.value == statusValue) return;
    selectedContactStatus.value = statusValue;
    
    // Reset selection/expansion index when switching filters
    openedIndex.value = -1;

    final lead = selectedLeadDataset.value;
    if (lead != null && lead.id != null) {
      _initContactsPagewise(lead.id!);
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // LEAD SELECTION
  // ─────────────────────────────────────────────────────────────────
  void onLeadSelected(AllLeadLeads dataset) {
    selectedLeadDataset.value = dataset;
    if (dataset.id != null && dataset.id!.isNotEmpty) {
      _initContactsPagewise(dataset.id!);
      fetchLeadStats();
    }

    final List<AllLeadLeadsFormIdFields> formFields =
        dataset.formId?.fields ?? [];
    final String formId = dataset.formId?.id ?? "";

    // Sync with PhoneStatusService (Single Point of Truth for Call Form)
    if (Get.isRegistered<PhoneStatusService>()) {
      final phoneService = Get.find<PhoneStatusService>();
      phoneService.currentLeadId = dataset.id;
      phoneService.currentFormId = formId;
      phoneService.currentFormFields = formFields;
    }
  }

  void clearLeadSelection() {
    selectedLeadDataset.value = null;
    contactQueue.clear();
    pagewiseContactsController?.dispose();
    pagewiseContactsController = null;
    totalContacts.value = 0;
    successful.value = 0;
    failed.value = 0;
    pending.value = 0;
    completed.value = 0;
    overallTotal.value = 0;
    update();
  }

  // ─────────────────────────────────────────────────────────────────
  // STATS FETCH
  // ─────────────────────────────────────────────────────────────────
  Future<void> fetchLeadStats() async {
    final lead = selectedLeadDataset.value;
    if (lead == null || lead.id == null) return;

    try {
      // 1. Get Overall Total count (No filter)
      final tResp = await _apiService.getCallLead(id: lead.id, page: 0, limit: 1, filterBy: null);
      overallTotal.value = tResp.total ?? 0;

      // 2. Get Pending count
      final pResp = await _apiService.getCallLead(id: lead.id, page: 0, limit: 1, filterBy: {"status": "pending"});
      pending.value = pResp.total ?? 0;

      // 3. Completed is everything else (Total - Pending)
      completed.value = (overallTotal.value - pending.value).clamp(0, overallTotal.value);

      // Keep successful/failed for internal use/rate calculation if needed
      final sResp = await _apiService.getCallLead(id: lead.id, page: 0, limit: 1, filterBy: {"status": "interested"});
      successful.value = sResp.total ?? 0;
      final fResp = await _apiService.getCallLead(id: lead.id, page: 0, limit: 1, filterBy: {"status": "not interested"});
      failed.value = fResp.total ?? 0;

      totalAttempts.value = successful.value + failed.value;
    } catch (e) {
      print("❌ fetchLeadStats error: $e");
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // CALL TIMER
  // ─────────────────────────────────────────────────────────────────
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

  // ─────────────────────────────────────────────────────────────────
  // AUTO-DIAL START
  // ─────────────────────────────────────────────────────────────────
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

    final queue =
        contactQueue
            .where(
              (l) =>
                  l.contact?.phone != null &&
                  l.contact!.phone!.isNotEmpty &&
                  (
                    // Current Status Match (Case Insensitive)
                    (l.status?.toLowerCase() == selectedContactStatus.value.toLowerCase()) ||
                    
                    // Pending fallback (null or empty also counts as pending)
                    (selectedContactStatus.value.toLowerCase() == 'pending' && (l.status == null || l.status!.isEmpty)) ||
                    
                    // Completed broad match (anything that is NOT pending or scheduled)
                    (selectedContactStatus.value.toLowerCase() == 'completed' && 
                     l.status?.toLowerCase() != 'pending' && 
                     l.status != null && 
                     l.status!.isNotEmpty && 
                     l.status?.toLowerCase() != 'scheduled')
                  ),
            )
            .map(
              (l) => {
                'id':
                    l.leadId ??
                    '', // Parent lead ID (consistent key across app)
                'leadContactId': l.id ?? '', // Specific contact record ID
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

    // Determine where to start: either from the user-selected contact or the first one
    int startIndex = 0;
    if (openedIndex.value != -1 && openedIndex.value < contactQueue.length) {
      final selectedContact = contactQueue[openedIndex.value];
      final qIndex = queue.indexWhere((l) => l['leadContactId'] == selectedContact.id);
      if (qIndex != -1) {
        startIndex = qIndex;
      }
    }

    overlayCtrl.callQueue = queue;
    overlayCtrl.currentQueueIndex.value = startIndex;
    overlayCtrl.isAutoCallMode.value = true;
    
    _syncWithOverlay(overlayCtrl);

    final firstLead = queue[startIndex];

    // Sync metadata with OverlayController & PhoneStatusService BEFORE dialing
    overlayCtrl.currentLeadId = firstLead['id'] ?? '';
    overlayCtrl.currentLeadContactId = firstLead['leadContactId'] ?? '';

    if (Get.isRegistered<PhoneStatusService>()) {
      final phoneService = Get.find<PhoneStatusService>();
      phoneService.currentLeadContactId = firstLead['leadContactId'] ?? '';
      phoneService.currentLeadId = firstLead['id'] ?? '';
      
      // Sync form metadata here (since OverlayController no longer pulls it)
      final dataset = selectedLeadDataset.value;
      if (dataset != null) {
        phoneService.currentFormId = dataset.formId?.id ?? "";
        phoneService.currentFormFields = dataset.formId?.fields ?? [];
      }
    }

    // Sync with background service
    FlutterBackgroundService().invoke('set_lead_info', {
      'leadId': overlayCtrl.currentLeadId,
      'leadContactId': overlayCtrl.currentLeadContactId,
      'phoneNumber': firstLead['number']!,
    });

    // Dial first contact
    overlayCtrl.makeDirectCall(firstLead['number']!);
  }

  void _syncWithOverlay(OverlayController overlayCtrl) {
    countdown.bindStream(overlayCtrl.countdown.stream);

    void refreshCurrentContact() {
      final index = overlayCtrl.currentQueueIndex.value;
      final cdValue = overlayCtrl.countdown.value;

      // Update status based on auto-mode, countdown, and pause state
      if (!overlayCtrl.isAutoCallMode.value) {
        status.value = 'idle';
      } else if (overlayCtrl.isPaused.value) {
        status.value = 'paused';
      } else if (cdValue > 0) {
        // Use dynamic to bypass circular dependency errors if they persist
        final dynamic dynOverlay = overlayCtrl;
        status.value = dynOverlay.isPreCallMode.value ? 'counting_down' : 'settled';
      } else {
        // If auto-mode is active, not paused, and no countdown, we are actively dialing
        status.value = 'dialing';
      }

      if (cdValue > 0) {
        // We are in countdown to NEXT lead
        if (index < overlayCtrl.callQueue.length) {
          final next = overlayCtrl.callQueue[index];
          currentContact.value = contactQueue.firstWhereOrNull(
            (l) => l.id == next['leadContactId'],
          );

          // Also update nextContact for preview
          if (index + 1 < overlayCtrl.callQueue.length) {
            final nextNext = overlayCtrl.callQueue[index + 1];
            nextContact.value = contactQueue.firstWhereOrNull(
              (l) => l.id == nextNext['leadContactId'],
            );
          } else {
            nextContact.value = null;
          }
        }
      } else {
        // We are DIALING or IDLE
        if (index >= 0 && index < overlayCtrl.callQueue.length) {
          final current = overlayCtrl.callQueue[index];
          currentContact.value = contactQueue.firstWhereOrNull(
            (l) => l.id == current['leadContactId'],
          );

          // Get the "Next" one too if available
          if (index + 1 < overlayCtrl.callQueue.length) {
            final next = overlayCtrl.callQueue[index + 1];
            nextContact.value = contactQueue.firstWhereOrNull(
              (l) => l.id == next['leadContactId'],
            );
          } else {
            nextContact.value = null;
          }

          // ── SYNC: Update PhoneStatusService for the CURRENT call ──────────
          if (Get.isRegistered<PhoneStatusService>()) {
            final ps = Get.find<PhoneStatusService>();
            ps.currentLeadId = current['id'];
            ps.currentLeadContactId = current['leadContactId'];

            // Restore form metadata
            final dataset = selectedLeadDataset.value;
            if (dataset != null) {
              ps.currentFormId = dataset.formId?.id ?? "";
              ps.currentFormFields = dataset.formId?.fields ?? [];
            }

            print(
              "🔄 Dialer Sync (Active): Lead=${ps.currentLeadId} | Contact=${ps.currentLeadContactId} | Form=${ps.currentFormId}",
            );
          }
        }
      }

      // Auto-expand the card for the currently active/dialing contact
      if (overlayCtrl.isAutoCallMode.value && currentContact.value != null) {
        final qIndex = contactQueue.indexWhere((l) => l.id == currentContact.value!.id);
        if (qIndex != -1 && openedIndex.value != qIndex) {
          openedIndex.value = qIndex;
        }
      } else if (!overlayCtrl.isAutoCallMode.value) {
        // If not dialing, don't force expansion unless the user manually did it
        // We can optionally reset openedIndex here if you want it to collapse when stopping
        // openedIndex.value = -1;
      }
    }

    final dynamic dynOverlay = overlayCtrl;
    ever(dynOverlay.currentQueueIndex, (_) => refreshCurrentContact());
    ever(dynOverlay.countdown, (_) => refreshCurrentContact());
    ever(dynOverlay.isPreCallMode, (_) => refreshCurrentContact());
    ever(dynOverlay.isPaused, (_) => refreshCurrentContact());

    // Listen to status updates from overlay
    ever(dynOverlay.lastUpdateEvent, (dynamic event) {
      if (event != null && event is Map) {
        updateContactStatusLocally(event['contactId']!, event['status']!);
      }
    });

    refreshCurrentContact();
  }

  // ─────────────────────────────────────────────────────────────────
  // CONTROLS
  // ─────────────────────────────────────────────────────────────────
  void pauseDialing() {
    if (status.value == 'dialing' || status.value == 'counting_down') {
      status.value = 'paused';
      if (Get.isRegistered<OverlayController>()) {
        Get.find<OverlayController>().pauseCountdown();
      }
    }
  }

  void resumeDialing() {
    if (status.value == 'paused') {
      if (Get.isRegistered<OverlayController>()) {
        Get.find<OverlayController>().resumeCountdown();
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

  // ─────────────────────────────────────────────────────────────────
  // SELECTION LOGIC
  // ─────────────────────────────────────────────────────────────────
  void onContactManualSelect(int index) {
    if (index < 0 || index >= contactQueue.length) {
      openedIndex.value = -1;
      return;
    }

    final bool isClosing = openedIndex.value == index;
    
    // 1. Immediately update expansion state
    openedIndex.value = isClosing ? -1 : index;
    
    // 2. Immediately update active contact for real-time UI highlight (no sticky selection)
    if (!isClosing) {
      currentContact.value = contactQueue[index];
    }

    // 3. If dialer is running, jump to this contact immediately in the background
    if (status.value != 'idle' && Get.isRegistered<OverlayController>()) {
      final overlayCtrl = Get.find<OverlayController>();
      if (overlayCtrl.isAutoCallMode.value && !isClosing) {
         final contact = contactQueue[index];
         final qIndex = overlayCtrl.callQueue.indexWhere((l) => l['leadContactId'] == contact.id);
         if (qIndex != -1) {
           // This will trigger the dialer to switch
           overlayCtrl.currentQueueIndex.value = qIndex;
         }
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // MANUAL SINGLE CALL
  // ─────────────────────────────────────────────────────────────────
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
        'id': lead.leadId ?? '', // Parent Lead ID
        'leadContactId': lead.id ?? '', // Specific Contact ID
        'name': lead.contact?.name ?? 'Unknown',
        'number': number,
      },
    ];
    overlayCtrl.currentQueueIndex.value = 0;
    overlayCtrl.isAutoCallMode.value = false;

    // Sync metadata with PhoneStatusService
    if (Get.isRegistered<PhoneStatusService>()) {
      final phoneService = Get.find<PhoneStatusService>();
      phoneService.currentLeadContactId = lead.id ?? "";
      phoneService.currentLeadId = lead.leadId ?? "";
      // formId and fields already synced via onLeadSelected, but we can ensure it here
      final currentDataset = selectedLeadDataset.value;
      if (currentDataset != null) {
        phoneService.currentFormId = currentDataset.formId?.id ?? "";
        phoneService.currentFormFields = currentDataset.formId?.fields ?? [];
      }
    }

    overlayCtrl.makeDirectCall(number);
  }

  // ─────────────────────────────────────────────────────────────────
  // UPDATE LOCAL STATUS
  // ─────────────────────────────────────────────────────────────────
  void updateContactStatusLocally(String contactId, String newStatus) {
    final index = contactQueue.indexWhere((c) => c.id == contactId);
    if (index != -1) {
      final oldStatus = contactQueue[index].status;
      contactQueue[index].status = newStatus;
      contactQueue.refresh();

      // Update counters locally
      if (oldStatus != newStatus) {
        if (oldStatus?.toLowerCase() == 'pending') {
          if (pending.value > 0) pending.value--;
        }
        
        if (newStatus.toLowerCase() == 'pending') {
          pending.value++;
        }

        // Recalculate completed dynamically
        completed.value = (overallTotal.value - pending.value).clamp(0, overallTotal.value);

        if (newStatus.toLowerCase() == 'interested') {
          successful.value++;
          totalAttempts.value++;
        } else if (newStatus.toLowerCase() == 'not interested' || newStatus.toLowerCase() == 'invalid' || newStatus.toLowerCase() == 'no response') {
          failed.value++;
          totalAttempts.value++;
        }
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // UTILS
  // ─────────────────────────────────────────────────────────────────
  String capitalizeEachWord(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<void> launchPhoneDialer(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final Uri url = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> launchSms(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final Uri url = Uri(scheme: 'sms', path: phone);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> launchWhatsApp(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    // Remove non-numeric characters for WhatsApp
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final Uri url = Uri.parse("https://wa.me/$cleanPhone");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> launchEmail(String? email) async {
    if (email == null || email.isEmpty) return;
    final Uri url = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'scheduled':
        return const Color(0xFF4F46E5);
      case 'completed':
        return const Color(0xFF10B981);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'cancelled':
        return const Color(0xFFEF4444);
      case 'interested':
        return const Color(0xFF8BC34A);
      case 'not interested':
        return const Color(0xFFF44336);
      case 'follow up':
        return const Color(0xFF9C27B0);
      case 'invalid':
        return const Color(0xFF757575);
      case 'no response':
        return const Color(0xFFBDBDBD);
      case 'answered':
        return const Color(0xFF10B981);
      default:
        return Get.theme.primaryColor;
    }
  }
}
