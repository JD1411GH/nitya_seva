import 'package:flutter/material.dart';

class Deepotsava extends StatefulWidget {
  @override
  _DeepotsavaState createState() => _DeepotsavaState();
}

class _DeepotsavaState extends State<Deepotsava>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animationRKC;
  late Animation<Offset> _animationRRG;
  late Animation<Offset> _animationMaking;
  late Animation<Offset> _animationAccounting;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration:
          const Duration(milliseconds: 500), // Reduced duration to 1 second
      vsync: this,
    );

    _animationRKC = Tween<Offset>(begin: Offset(-1, 0), end: Offset(0, 0))
        .animate(_controller);
    _animationRRG = Tween<Offset>(begin: Offset(1, 0), end: Offset(0, 0))
        .animate(_controller);
    _animationMaking = Tween<Offset>(begin: Offset(-1, 0), end: Offset(0, 0))
        .animate(_controller);
    _animationAccounting = Tween<Offset>(begin: Offset(1, 0), end: Offset(0, 0))
        .animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SlideTransition(
            position: _animationRKC,
            child: CardWidget(
              image: 'assets/images/RKC.png',
              text: 'RKC Deepam Sales',
              isImageLeft: true,
            ),
          ),
          SlideTransition(
            position: _animationRRG,
            child: CardWidget(
              image: 'assets/images/RRG.png',
              text: 'RRG Deepam Sales',
              isImageLeft: false,
            ),
          ),
          SlideTransition(
            position: _animationMaking,
            child: CardWidget(
              image: 'assets/images/deepotsava.jpg',
              text: 'Deepam Making',
              isImageLeft: true,
            ),
          ),
          SlideTransition(
            position: _animationAccounting,
            child: CardWidget(
              image: 'assets/images/icon_cash.png',
              text: 'Accounting',
              isImageLeft: false,
            ),
          ),
        ],
      ),
    );
  }
}

class CardWidget extends StatelessWidget {
  final String image;
  final String text;
  final bool isImageLeft;

  CardWidget(
      {required this.image, required this.text, required this.isImageLeft});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        child: Row(
          children: <Widget>[
            if (isImageLeft) ...[
              Image.asset(image, width: 50, height: 50),
              SizedBox(width: 20),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontFamily: 'Cursive',
                    fontSize: 20,
                  ),
                ),
              ),
            ] else ...[
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontFamily: 'Cursive',
                    fontSize: 20,
                  ),
                ),
              ),
              SizedBox(width: 20),
              Image.asset(image, width: 50, height: 50),
            ],
          ],
        ),
      ),
    );
  }
}
