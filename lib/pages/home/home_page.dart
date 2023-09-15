import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math';
import '../../utils/colors.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../widgets/custom_text_field.dart';

class HomePage extends StatefulWidget {
  BuildContext context;
  HomePage({required this.context, super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  double x = 0;
  double y = 0;
  int z = 0;
  Widget image = Image.asset('assets/images/img.png');

  final List<Map<String, dynamic>> _projections = [
    {
      'name': 'wgs84Mercator',
      'eccentricity': 0.0818191908426,
    },
    {
      'name': 'sphericalMercator',
      'eccentricity': 0,
    },
  ];
  List _fromGeoToPixels(double lat, double long, Map projection, int z) {
    double x_p, y_p;
    List pixelCoords;
    double rho;
    double pi = 3.141592653589793;
    double beta;
    double phi;
    double theta;
    double e = projection['eccentricity'];

    rho = pow(2, z + 8) / 2;
    beta = lat * pi / 180;
    phi = (1 - e * sin(beta)) / (1 + e * sin(beta));
    theta = tan(pi / 4 + beta / 2) * pow(phi, e / 2);

    x_p = rho * (1 + long / 180);
    y_p = rho * (1 - log(theta) / pi);

    pixelCoords = [x_p, y_p];

    return pixelCoords;
  }
  List _fromPixelsToTileNumber(double x, double y) {
    return [
      (x / 256).floor(),
      (y / 256).floor(),
    ];
  }
  List _tileNumber = ['0', '0'];
   late var _params = {};

  _changeTileNumber() {
    _params = {
      'z': z,
      'geoCoords': [x, y],
      'projection': _projections[0],
    };

    var pixelCoords = _fromGeoToPixels(
      (_params['geoCoords'] as List<double>)[0],
      (_params['geoCoords'] as List<double>)[1],
      _params['projection'] as Map<String, dynamic>,
      _params['z'] as int,
    );
    _tileNumber = _fromPixelsToTileNumber(pixelCoords[0], pixelCoords[1]);
  }

  CustomDeviceType _getCustomDeviceType() {
    var deviceType = getDeviceType(MediaQuery.of(widget.context).size);
    switch(deviceType) {
        case DeviceScreenType.desktop:
          return CustomDeviceType.desktop;
        case DeviceScreenType.mobile:
          return CustomDeviceType.mobile;
        default:
          return CustomDeviceType.mobile;
    }
}

  _getImage() {
    const snackBar = SnackBar(
      content: Text("Try change coordinates or zoom!"),
    );

    setState(() {
      image = Image.network(
        'https://core-carparks-renderer-lots.maps.yandex.net/maps-rdr-carparks/tiles?l=carparks&x=${_tileNumber[0]}&y=${_tileNumber[1]}&z=${_params['z']}&scale=1&lang=ru_RU',
        fit: BoxFit.fitWidth,
        errorBuilder: (BuildContext context, Object exception,
            StackTrace? stackTrace) {
          WidgetsBinding.instance.addPostFrameCallback((_) => ScaffoldMessenger.of(context).showSnackBar(snackBar));
          return Image.asset('assets/images/img.png');
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    var type = _getCustomDeviceType();
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: Container(
              margin: EdgeInsets.only(top: 5.h),
              child: const Text(
                'Parking',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: SingleChildScrollView(
                child: Container(
                  width: double.maxFinite,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomTextField(deviceType: type, hintText: 'X coordinates ...', func: (val) {
                        x = double.parse(val);
                      }),
                      SizedBox(height: 16.h,),
                      CustomTextField(deviceType: type, hintText: 'Y coordinates ...', func: (val) {
                        y = double.parse(val);
                      }),
                      SizedBox(height: 8.h,),
                      CustomTextField(deviceType: type, hintText: 'Zoom ...', type: TextViewType.zoom, func: (val) {
                        z = int.parse(val);
                      }),
                      SizedBox(height: 40.h,),
                      ElevatedButton(
                        onPressed: () {
                          _changeTileNumber();
                          _getImage();
                        },
                        style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: AppColors.primaryElement.withOpacity(0.5),
                            padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 16),
                            textStyle: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                            )
                        ),
                        child: const Text('Get tile'),
                      ),
                      SizedBox(height: 16.h,),
                      Text(
                        'X = ${_tileNumber[0]}      Y = ${_tileNumber[1]}',
                        style: TextStyle(
                            color: AppColors.primarySecondaryElementText,
                            fontWeight: FontWeight.w600,
                            fontSize: type == CustomDeviceType.mobile ? 16.sp : 6.sp
                        ),
                      ),
                      SizedBox(height: 16.h,),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 16.w),
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        height: type == CustomDeviceType.mobile ? 200.h : 300.h,
                        width: type == CustomDeviceType.mobile ? 200.h : 300.h,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(12.r)),
                            color: AppColors.primaryElement.withOpacity(0.2)
                        ),
                        child: Center(
                          child: image
                        ),
                      ),
                    ],
                  ),
                ))
            ),
          ],
        )
      )
    );
  }
}

