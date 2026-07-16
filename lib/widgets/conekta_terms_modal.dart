import 'package:flutter/material.dart';
import 'package:ventalink_mobile/utils/app_colors.dart';
import 'package:ventalink_mobile/widgets/custom_button.dart';

/// Native equivalent of ConektaTermsAndConditionModal.tsx. Shown before a
/// card is charged; returns true via Navigator.pop when the user agrees.
class ConektaTermsModal extends StatefulWidget {
  const ConektaTermsModal({super.key});

  @override
  State<ConektaTermsModal> createState() => _ConektaTermsModalState();
}

class _ConektaTermsModalState extends State<ConektaTermsModal> {
  bool _checked = false;

  static const List<List<String>> _sections = [
    ["1. Acceptance of Terms", "By using this platform, you agree to these Terms."],
    ["2. Payment Services", "Payments are processed via Conekta. You confirm authorization."],
    ["3. Prohibited Activities", "No fraud, no unauthorized payments, no abuse."],
    ["4. Chargebacks", "False disputes may result in legal action."],
    ["5. User Consent", "You confirm full understanding of the transaction."],
    ["6. Identity Verification", "We may request verification documents."],
    ["7. Liability", "Platform is not liable for user negligence."],
    ["8. Law", "Governed by Mexican law."],
    ["9. Updates", "Terms may change anytime."],
    ["10. Agreement", "You must accept before continuing."],
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 560),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text("TERMS AND CONDITIONS AGREEMENT", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  ),
                  IconButton(onPressed: () => Navigator.of(context).pop(false), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(right: 8, bottom: 8),
                        child: Text("For Use of Payment Services via Conekta", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      ),
                      ..._sections.map(
                        (section) => Padding(
                          padding: const EdgeInsets.only(right: 8, bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(section[0], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                              const SizedBox(height: 2),
                              Text(section[1], style: const TextStyle(fontSize: 12, color: AppColors.textGrey, height: 1.4)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              InkWell(
                onTap: () => setState(() => _checked = !_checked),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(value: _checked, onChanged: (value) => setState(() => _checked = value ?? false), activeColor: AppColors.primary),
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: 12, right: 8),
                          child: Text(
                            "I authorize this charge to my card and confirm that this purchase is voluntary. I understand this is not a deposit or guaranteed return, and I agree to the terms and conditions.",
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CustomButton(
                  label: "I Agree",
                  onPressed: _checked ? () => Navigator.of(context).pop(true) : null,
                  height: 48,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
