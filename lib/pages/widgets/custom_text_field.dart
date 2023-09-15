import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/colors.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

enum TextViewType {
  coordinates,
  zoom
}

enum CustomDeviceType {
  desktop,
  mobile
}

class CustomTextField extends StatefulWidget {
  CustomDeviceType deviceType;
  String hintText;
  TextViewType type;
  Function(dynamic) func;

  CustomTextField({ required this.deviceType, required this.hintText, required this.func, this.type = TextViewType.coordinates, super.key});

  @override
  State<CustomTextField> createState() => CustomTextFieldState();
}

class CustomTextFieldState extends State<CustomTextField> {
  Color containerColor = AppColors.primaryFourthElementText.withOpacity(0.5);
  int isValid = 0;
  final TextEditingController controller = TextEditingController();

  var coordinatesMask = MaskTextInputFormatter(
      mask: '##.######',
      filter: { "#": RegExp(r'[0-9]') },
      type: MaskAutoCompletionType.lazy
  );

  var zoomMask = MaskTextInputFormatter(
      mask: '##',
      filter: { "#": RegExp(r'[0-9]') },
      type: MaskAutoCompletionType.lazy
  );

  @override
  Widget build(BuildContext context) {
    return Container(
        width: widget.deviceType == CustomDeviceType.mobile ? 325.w : 100.w,
        height: widget.deviceType == CustomDeviceType.mobile ? 60.h : 40.h,
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.only(top: widget.deviceType == CustomDeviceType.mobile ? 5.h : 8.h, bottom: 5.h),
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.all(Radius.circular(widget.deviceType == CustomDeviceType.mobile ? 12.r : 10.r)),
        ),
        child: TextField(
          controller: controller,
          inputFormatters: getMask(widget.type),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: widget.hintText,
            border: const OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.grey
                )
            ),

            enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.transparent
                )
            ),
            disabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.transparent
                )
            ),
            focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.transparent
                )
            ),
          ),
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontSize: widget.deviceType == CustomDeviceType.mobile ? 16.sp : 4.sp
          ),
          onChanged: (val) {
            if (widget.type == TextViewType.coordinates) {
              validateCoordinates(val);
            }
            if (controller.text.isEmpty) {
              widget.func('0');
            } else {
              widget.func(controller.text);
            }
          },
        ),
    );
  }

  void validateCoordinates(String val) {
    if (val.isEmpty) {
      setState(() {
        isValid = 0;
        containerColor = AppColors.primaryFourthElementText.withOpacity(0.5);
      });
    } else if (val.length == 9) {
      setState(() {
        containerColor = AppColors.primaryFourthElementText.withOpacity(0.5);
        isValid = 1;
      });
    } else {
      setState(() {
        isValid = 0;
        containerColor = AppColors.red.withOpacity(0.15);
      });
    }
  }

  List<MaskTextInputFormatter> getMask(TextViewType type) {
    if (type == TextViewType.coordinates) {
      return [coordinatesMask];
    } else {
      return [zoomMask];
    }
  }
}
