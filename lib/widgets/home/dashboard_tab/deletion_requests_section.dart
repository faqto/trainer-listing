import 'package:fit_ed/models/deletion_request.dart';
import 'package:fit_ed/pages/home/home_constants.dart';
import 'package:flutter/material.dart';

class DeletionRequestsSection extends StatefulWidget {
  final List<DeletionRequest> requests;
  final Future<void> Function(DeletionRequest request) onApprove;
  final Future<void> Function(DeletionRequest request) onReject;

  const DeletionRequestsSection({
    super.key,
    required this.requests,
    required this.onApprove,
    required this.onReject,
  });

  @override
  State<DeletionRequestsSection> createState() =>
      _DeletionRequestsSectionState();
}

class _DeletionRequestsSectionState extends State<DeletionRequestsSection> {
  String? _processingId;

  Future<void> _process(
    DeletionRequest request,
    Future<void> Function(DeletionRequest request) action,
  ) async {
    if (_processingId != null) return;
    setState(() => _processingId = request.id);
    try {
      await action(request);
    } finally {
      if (mounted) setState(() => _processingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: cardBorderColor),
        borderRadius: BorderRadius.circular(18),
        boxShadow: premiumCardShadows,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Deletion Requests',
                  style: TextStyle(
                    color: inkColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${widget.requests.length} pending',
                style: const TextStyle(
                  color: mutedColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (widget.requests.isEmpty)
            const Text(
              'No pending data deletion requests.',
              style: TextStyle(color: mutedColor),
            )
          else
            ...widget.requests.map((request) {
              final isProcessing = _processingId == request.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DeletionRequestCard(
                  request: request,
                  isProcessing: isProcessing,
                  onReject: () => _process(request, widget.onReject),
                  onApprove: () => _process(request, widget.onApprove),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _DeletionRequestCard extends StatelessWidget {
  final DeletionRequest request;
  final bool isProcessing;
  final VoidCallback onReject;
  final VoidCallback onApprove;

  const _DeletionRequestCard({
    required this.request,
    required this.isProcessing,
    required this.onReject,
    required this.onApprove,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: cardBorderColor),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              request.clientName.isEmpty
                  ? request.clientEmail
                  : request.clientName,
              style: const TextStyle(
                color: inkColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (request.reason.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(request.reason, style: const TextStyle(color: mutedColor)),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isProcessing ? null : onReject,
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: isProcessing ? null : onApprove,
                    child: isProcessing
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
