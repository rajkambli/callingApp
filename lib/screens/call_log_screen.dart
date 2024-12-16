import 'package:flutter/material.dart';
import 'package:call_log/call_log.dart';
import 'package:permission_handler/permission_handler.dart';

class CallLogScreen extends StatefulWidget {
  const CallLogScreen({Key? key}) : super(key: key);

  @override
  State<CallLogScreen> createState() => _CallLogScreenState();
}

class _CallLogScreenState extends State<CallLogScreen> {
  List<CallLogEntry> _callLogs = [];

  @override
  void initState() {
    super.initState();
    _fetchCallLogs();
  }

  Future<void> _fetchCallLogs() async {

    if (await Permission.phone.request().isGranted) {
      try {

        Iterable<CallLogEntry> entries = await CallLog.get();
        setState(() {
          _callLogs = entries.toList();
        });
      } catch (e) {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load call logs: $e')),
        );
      }
    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone permission is required.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call Logs'),
      ),
      body: _callLogs.isEmpty
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : ListView.builder(
        itemCount: _callLogs.length,
        itemBuilder: (context, index) {
          CallLogEntry log = _callLogs[index];
          return ListTile(
            leading: Icon(
              log.callType == CallType.incoming
                  ? Icons.call_received
                  : log.callType == CallType.outgoing
                  ? Icons.call_made
                  : Icons.call_missed,
              color: log.callType == CallType.missed ? Colors.red : Colors.green,
            ),
            title: Text(log.name ?? 'Unknown'),
            subtitle: Text(
              '${log.number ?? 'No Number'}\n${log.timestamp != null ? DateTime.fromMillisecondsSinceEpoch(log.timestamp!).toString() : ''}',
            ),
            isThreeLine: true,
            trailing: Text('${log.duration ?? 0} sec'),
          );
        },
      ),
    );
  }
}
