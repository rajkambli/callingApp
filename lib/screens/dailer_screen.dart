import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DialerScreen extends StatefulWidget {
  const DialerScreen({Key? key}) : super(key: key);

  @override
  State<DialerScreen> createState() => _DialerScreenState();
}

class _DialerScreenState extends State<DialerScreen> {
  String _phoneNumber = '';


  void _addDigit(String digit) {
    setState(() {
      _phoneNumber += digit;
    });
  }


  void _deleteDigit() {
    if (_phoneNumber.isNotEmpty) {
      setState(() {
        _phoneNumber = _phoneNumber.substring(0, _phoneNumber.length - 1);
      });
    }
  }


  Future<void> _makeCall() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: _phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch phone dialer')),
      );
    }
  }


  Widget _dialButton(String text, {VoidCallback? onPressed}) {
    return GestureDetector(
      onTap: onPressed ?? () => _addDigit(text),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey,
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dialer'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Text(
              _phoneNumber,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ),

          // Dial Pad
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              padding: EdgeInsets.all(40),
              shrinkWrap: true,
              crossAxisSpacing: 30,
              mainAxisSpacing: 30,
              children: [
                for (var i = 1; i <= 9; i++) _dialButton('$i'),
                _dialButton('*'),
                _dialButton('0'),
                _dialButton('#'),
              ],
            ),
          ),

          SizedBox(
            width: MediaQuery.sizeOf(context).width,
            child: Stack(
              alignment: Alignment.center,
              children: [
                FloatingActionButton(

                  backgroundColor: Colors.green,
                  onPressed: _makeCall,
                  child: const Icon(Icons.call, color: Colors.white, size: 32),
                ),
                if(_phoneNumber.isNotEmpty)Positioned(
                  right: 50,
                  child: IconButton(
                    icon: const Icon(Icons.backspace, size: 32),
                    onPressed: _deleteDigit,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
