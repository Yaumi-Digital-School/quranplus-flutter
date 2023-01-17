import 'package:flutter/material.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_colors.dart';
import 'package:qurantafsir_flutter/shared/constants/qp_text_style.dart';
import 'package:qurantafsir_flutter/shared/constants/theme.dart';

class InputTotalPagesTextField extends StatelessWidget {
  final void Function(String) onChanged;
  final int? defaultValue;

  const InputTotalPagesTextField({
    Key? key,
    required this.onChanged,
    this.defaultValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      width: 56,
      child: TextField(
        controller: TextEditingController(
          text: defaultValue != null ? defaultValue.toString() : "",
        ),
        cursorColor: Colors.black,
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        style: buttonMedium3.copyWith(color: neutral400),
        onChanged: onChanged,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.never,
          contentPadding: EdgeInsets.zero,
          label: Center(
            child: Text(
              "0",
              style: buttonMedium3.copyWith(color: neutral400),
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: neutral500, width: 0.5),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: neutral500, width: 0.5),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: neutral500, width: 0.5),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
    );
  }
}

class TextFieldWithDropdown extends StatelessWidget {
  TextFieldWithDropdown({
    Key? key,
    required this.options,
    required this.onSelect,
    this.label,
    this.maxOptionsInContainer = 3,
    this.additionalInformation,
  }) : super(key: key);

  final List<String> options;
  final Function(String) onSelect;
  final String? label;
  final RichText? additionalInformation;

  final GlobalKey textFieldKey = GlobalKey();
  final int maxOptionsInContainer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          _FieldLabel(
            label: label!,
          ),
        // Autocomplete(optionsBuilder: optionsBuilder),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text == '') {
              return options;
            }

            return options.where((String option) {
              return option
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
            });
          },
          optionsViewBuilder: (_, onSelected, options) {
            final RenderBox textFieldBox =
                textFieldKey.currentContext!.findRenderObject() as RenderBox;
            final double textFieldWidth = textFieldBox.size.width;
            final int currOptionsInContainer =
                (options.length >= maxOptionsInContainer)
                    ? maxOptionsInContainer
                    : options.length;
            final double maxContainerHeight =
                (currOptionsInContainer * 28) + 14;

            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                child: SizedBox(
                  height: maxContainerHeight,
                  // width: 200,
                  width: textFieldWidth,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                    ),
                    itemCount: options.length,
                    itemBuilder: (BuildContext context, int index) {
                      final String option = options.elementAt(index);

                      return GestureDetector(
                        onTap: () {
                          onSelect(option);
                          onSelected(option);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                          ),
                          child: Text(
                            option,
                            style: QPTextStyle.subHeading4SemiBold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
          fieldViewBuilder: (
            BuildContext context,
            TextEditingController textEditingController,
            FocusNode focusNode,
            Function onFieldSubmitted,
          ) {
            return SizedBox(
              height: 40,
              child: TextFormField(
                key: textFieldKey,
                controller: textEditingController,
                focusNode: focusNode,
                textAlign: TextAlign.center,
                style: QPTextStyle.subHeading4SemiBold,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(8),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: QPColors.blackSoft,
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                ),
              ),
            );
          },
        ),
        if (additionalInformation != null) ...[
          const SizedBox(
            height: 4,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              additionalInformation!,
            ],
          ),
        ],
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({
    Key? key,
    required this.label,
  }) : super(key: key);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: QPTextStyle.subHeading4Medium,
      ),
    );
  }
}

class FormFieldWidget extends StatelessWidget {
  const FormFieldWidget({
    Key? key,
    this.label,
    this.additionalInformation,
    required this.onChange,
    this.hintTextForm,
    this.iconForm,
    this.validator,
  }) : super(key: key);

  final String? label;
  final RichText? additionalInformation;
  final void Function(String)? onChange;
  final String? hintTextForm;
  final Icon? iconForm;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null)
            Column(
              children: [
                _FieldLabel(
                  label: label!,
                ),
                const SizedBox(
                  height: 8,
                ),
              ],
            ),
          TextFormField(
            validator: validator == null ? null : (value) => validator!(value),
            cursorColor: Colors.black,
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            style: QPTextStyle.subHeading4SemiBold,
            onChanged: onChange,
            decoration: InputDecoration(
              prefixIcon: iconForm,
              floatingLabelBehavior: FloatingLabelBehavior.never,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 8,
              ),
              hintText: hintTextForm,
              hintStyle: QPTextStyle.subHeading4Regular
                  .copyWith(color: QPColors.blackFair),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: neutral500, width: 0.5),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: neutral500, width: 0.5),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: neutral500, width: 0.5),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
          ),
          if (additionalInformation != null) ...[
            const SizedBox(
              height: 12,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                additionalInformation!,
              ],
            ),
          ],
        ],
      ),
    );
  }
}
