import 'package:flutter/material.dart';
import 'package:note_app/data/local/db_helper.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, dynamic>> allNotes = [];
  DbHelper? dbRef;

  final TextEditingController _title = TextEditingController();
  final TextEditingController _desc = TextEditingController();

  @override
  void initState() {
    super.initState();
    dbRef = DbHelper.getInstance;
    getNotes();
  }

  void getNotes() async {
    allNotes = await dbRef!.getAllNotes();
    //eta to asynchronous. aste time lagte pare. but amr jonne to ui wait korbe na. tai setstate mere desi jate data elei abr reload hoy. etake handle korte obosso Future Builder use kora hoy.
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
      ),
      body: allNotes.isNotEmpty
          ? ListView.builder(
              itemCount: allNotes.length,
              itemBuilder: (_, index) {
                return Card(
                  elevation: 2,
                  margin:
                      const EdgeInsets.only(left: 10, right: 10, bottom: 15),
                  child: ListTile(
                      tileColor: const Color(0xFFF5F0FF),
                      leading: Text(
                        "${index + 1}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      title: Text(
                        allNotes[index][dbRef!.COLUMN_NOTE_TITLE],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(allNotes[index][dbRef!.COLUMN_NOTE_DESC]),
                      trailing: SizedBox(
                        width: 65,
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) {
                                      return _bottomSheet(
                                          isEdit: true,
                                          initialTitleValue: allNotes[index]
                                              [dbRef!.COLUMN_NOTE_TITLE],
                                          initialDesc: allNotes[index]
                                              [dbRef!.COLUMN_NOTE_DESC],
                                          sNo: allNotes[index]
                                              [dbRef!.COLUMN_NOTE_SNO]);
                                    });
                              },
                              child: Container(
                                  height: 30,
                                  width: 30,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    color: Colors.grey,
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  )),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            InkWell(
                              onTap: () async {
                                bool check = await dbRef!.deleteNote(
                                    sNo: allNotes[index][dbRef!.COLUMN_NOTE_SNO]
                                        .toString());

                                if (check) {
                                  getNotes();
                                }
                              },
                              child: Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: Colors.red,
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          ],
                        ),
                      )),
                );
              })
          : const Center(
              child: Text("No Notes yet."),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) {
                return _bottomSheet();
              });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _bottomSheet(
      {isEdit = false, sNo = 0, initialTitleValue, initialDesc}) {
    return Container(
      padding: EdgeInsets.only(
          top: 11,
          left: 11,
          right: 11,
          bottom: 11 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isEdit ? "Edit Note" : "Add Note",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 11,
          ),
          TextField(
            controller: _title..text = initialTitleValue ?? "",
            decoration: InputDecoration(
                label: const Text("Title"),
                hintText: "Enter title here",
                focusedBorder:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(11)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11))),
          ),
          const SizedBox(
            height: 11,
          ),
          TextField(
            controller: _desc..text = initialDesc ?? "",
            maxLines: 6,
            decoration: InputDecoration(
                label: const Text("Desc"),
                hintText: "Enter Description here",
                focusedBorder:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(11)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11))),
          ),
          const SizedBox(
            height: 11,
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                    onPressed: () async {
                      final title = _title.text;
                      final desc = _desc.text;

                      if (title == '' || desc == '') {
                        return;
                      }

                      bool check = isEdit
                          ? await dbRef!
                              .updateNote(s_no: sNo, title: title, desc: desc)
                          : await dbRef!.addNote(nTitle: title, nDesc: desc);
                      if (check) {
                        getNotes();
                        setState(() {});
                      }
                      Navigator.pop(context);
                      _title.clear();
                      _desc.clear();
                    },
                    child: const Text("Add Note")),
              ),
              const SizedBox(
                width: 5,
              ),
              Expanded(
                child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel")),
              )
            ],
          )
        ],
      ),
    );
  }
}
