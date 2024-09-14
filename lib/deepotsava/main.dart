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
      duration: const Duration(seconds: 1),
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

  void _onRKCDeepamSalesTap() {
    print('RKC Deepam Sales tapped');
  }

  void _onRRGDeepamSalesTap() {
    print('RRG Deepam Sales tapped');
  }

  void _onDeepamMakingTap() {
    print('Deepam Making tapped');
  }

  void _onAccountingTap() {
    print('Accounting tapped');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Deepotsava'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SlideTransition(
              position: _animationRKC,
              child: GestureDetector(
                onTap: _onRKCDeepamSalesTap,
                child: CardWidget(
                  image: 'assets/images/RKC.png',
                  text: 'RKC Deepam Sales',
                  isImageLeft: true,
                  color: Colors.deepOrange, // Set desired card color
                  textColor: Colors.white, // Set desired text color
                ),
              ),
            ),
            SlideTransition(
              position: _animationRRG,
              child: GestureDetector(
                onTap: _onRRGDeepamSalesTap,
                child: CardWidget(
                  image: 'assets/images/RRG.png',
                  text: 'RRG Deepam Sales',
                  isImageLeft: false,
                  color: Colors.green, // Set desired card color
                  textColor: Colors.black, // Set desired text color
                ),
              ),
            ),
            SlideTransition(
              position: _animationMaking,
              child: GestureDetector(
                onTap: _onDeepamMakingTap,
                child: CardWidget(
                  image: 'assets/images/deepotsava.jpg',
                  text: 'Deepam Making',
                  isImageLeft: true,
                  color: Colors.blue, // Set desired card color
                  textColor: Colors.yellow, // Set desired text color
                ),
              ),
            ),
            SlideTransition(
              position: _animationAccounting,
              child: GestureDetector(
                onTap: _onAccountingTap,
                child: CardWidget(
                  image: 'assets/images/icon_cash.png',
                  text: 'Accounting',
                  isImageLeft: false,
                  color: Colors.yellow, // Set desired card color
                  textColor: Colors.red, // Set desired text color
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CardWidget extends StatelessWidget {
  final String image;
  final String text;
  final bool isImageLeft;
  final Color color; // Add color parameter
  final Color textColor; // Add textColor parameter

  CardWidget({
    required this.image,
    required this.text,
    required this.isImageLeft,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color, // Use the color parameter
      margin: EdgeInsets.all(10),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        child: Row(
          children: <Widget>[
            if (isImageLeft) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(image, width: 80, height: 80),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cursive',
                    fontSize: 32, // Increased font size
                    fontWeight: FontWeight.bold,
                    color: textColor, // Use the textColor parameter
                  ),
                  overflow: TextOverflow.visible, // Ensure text wraps
                ),
              ),
            ] else ...[
              Expanded(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cursive',
                    fontSize: 32, // Increased font size
                    fontWeight: FontWeight.bold,
                    color: textColor, // Use the textColor parameter
                  ),
                  overflow: TextOverflow.visible, // Ensure text wraps
                ),
              ),
              SizedBox(width: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(image, width: 80, height: 80),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
