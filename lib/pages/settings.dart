import "package:expense_tracker/pages/home_page.dart";
import "package:flutter/material.dart";

class MySettings extends StatefulWidget {
  const MySettings({super.key});

  @override
  State<MySettings> createState() => _MySettingsState();
}

class _MySettingsState extends State<MySettings> {
  bool isSwitched = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.blueAccent,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            );
          },
        ),
        title: const Center(
            child: Text(
          'S E T T I N G S',
          style: TextStyle(color: Colors.white),
        )),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 30, right: 30, top: 20),
          child: Column(
            children: [
              SizedBox(
                height: 300,
                width: 350,
                child: ListView(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.grey.shade900,
                          borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        title: const Text(
                          'Dark Mode',
                          style: TextStyle(color: Colors.white),
                        ),
                        trailing: Switch(
                          value: isSwitched,
                          onChanged: (value) {
                            setState(() {
                              isSwitched = value;
                            });
                          },
                          activeTrackColor: Colors.lightGreenAccent,
                          activeColor: Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
