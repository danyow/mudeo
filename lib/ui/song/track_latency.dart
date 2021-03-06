import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mudeo/constants.dart';
import 'package:mudeo/utils/localization.dart';

class TrackLatency extends StatefulWidget {
  TrackLatency({
    @required this.delay,
    @required this.onDelayAccepted,
    @required this.onDelayChanged,
  });

  final int delay;
  final Function(int) onDelayAccepted;
  final Function(int) onDelayChanged;

  @override
  _TrackLatencyState createState() => _TrackLatencyState();
}

class _TrackLatencyState extends State<TrackLatency> {
  int _delay;
  TextEditingController _delayController;

  static const platform = const MethodChannel('mudeo.app/calibrate');

  @override
  void initState() {
    super.initState();

    _delay = widget.delay.toInt();
    _delayController = TextEditingController();
    _delayController.text = '$_delay';
  }

  @override
  void dispose() {
    _delayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);

    return AlertDialog(
      title: Text(localization.trackAdjustment),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Slider(
                  min: kMinLatencyDelay.toDouble(),
                  max: kMaxLatencyDelay.toDouble(),
                  value: _delay.toDouble(),
                  onChanged: (value) {
                    setState(() {
                      _delay = value.toInt();
                      _delayController.text = '${value.toInt()}';
                    });
                    widget.onDelayChanged(_delay);
                  },
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                flex: 1,
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: _delayController,
                  decoration: InputDecoration(
                    labelText: localization.milliseconds,
                  ),
                  onChanged: (String value) {
                    setState(() {
                      int delay = int.parse(value);
                      if (delay > kMaxLatencyDelay) {
                        delay = kMaxLatencyDelay;
                      } else if (delay < kMinLatencyDelay) {
                        delay = kMinLatencyDelay;
                      }
                      _delay = delay;
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Expanded(
                child: RaisedButton(
                  color: Colors.grey,
                  child: Text(localization.cancel),
                  onPressed: () {
                    Navigator.pop(context);
                    /*
                    setState(() {
                      _delayController.text = '0';
                      _delay = 0;
                    });
                    */
                  },
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: RaisedButton(
                  child: Text(localization.done),
                  onPressed: () {
                    widget.onDelayAccepted(_delay);
                    Navigator.pop(context);
                  },
                ),
              ),
              /*
                      Expanded(
                        child: RaisedButton(
                          child: Text(
                            localization.calibrate,
                          ),
                          onPressed: () async {
                            try {
                              final int result =
                                  await platform.invokeMethod('getDelay');
                              print('Delay: $result');
                            } on PlatformException catch (e) {
                              print('Error: ${e.message}');
                            }
                          },
                        ),
                      )
                      */
            ],
          ),
        ],
      ),
    );
  }
}
