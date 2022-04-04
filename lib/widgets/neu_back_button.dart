import 'package:flutter/material.dart';

class AppBackButton extends StatefulWidget {
  final BuildContext context;
  final Color? color;
  final Color? iconColor;
  final double bevel;
  const AppBackButton(this.context, {Key? key, this.color, this.iconColor, this.bevel = 5.0}) : super(key: key);
  @override
  _AppBackButtonState createState() => _AppBackButtonState();
}

class _AppBackButtonState extends State<AppBackButton> {
  ModalRoute<dynamic>? parentRoute;
  bool? canPop = false;
  @override
  void initState() {
    parentRoute = ModalRoute.of(widget.context);
    setState(() {
      canPop = parentRoute?.canPop;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return canPop == true
        ? Padding(
            padding: const EdgeInsets.only(left: 10, top: 8, bottom: 8),
            child: BackButton(
              color: widget.color ?? Theme.of(context).scaffoldBackgroundColor,
              // decoration: Decoration(
              //   color: widget.color ?? Theme.of(context).scaffoldBackgroundColor,
              //   borderRadius: BorderRadius.circular(10),
              // ),
              //padding: const EdgeInsets.all(10),
              // bevel: widget.bevel,
              onPressed: () {
                Navigator.of(context).pop();
              },
              // child: Icon(
              //   Icons.arrow_back_ios_outlined,
              //   size: 22,
              //   color: widget.iconColor,
              // ),
            ),
          )
        : Container();
  }
}
