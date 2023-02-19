import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:realm/realm.dart';
import 'model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Realm Demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Realm Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const _paddingEdgeInsets = 10.0;
  static const _headerTextFontSize = 20.0;

  final _pageScrollController = ScrollController();
  final _addFormKey = GlobalKey<FormState>();
  final _addMakeTextController = TextEditingController();
  final _addModelTextController = TextEditingController();
  final _addKiloTextController = TextEditingController();
  final _queryFormKey = GlobalKey<FormState>();
  final _queryMakeTextController = TextEditingController();
  final _queryModelTextController = TextEditingController();
  final _queryKiloTextController = TextEditingController();
  final _deleteFormKey = GlobalKey<FormState>();
  final _deleteMakeTextController = TextEditingController();
  final _deleteModelTextController = TextEditingController();
  final _deleteKiloTextController = TextEditingController();

  final _realmService = RealmService();

  final _queryResultTextController = TextEditingController();

  Widget _buildModelInfoCard() => Card(
        color: Theme.of(context).secondaryHeaderColor,
        child: Padding(
          padding: const EdgeInsets.all(_paddingEdgeInsets),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Model info',
                style: TextStyle(
                  fontSize: _headerTextFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '''
@RealmModel()
class $Car {
  @PrimaryKey()
  late ObjectId id;
  late String make;
  late String model;
  int? kilometers = 500;
}''',
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
              Text(_realmService.path()),
            ],
          ),
        ),
      );

  Widget _buildAddCard() => Card(
        color: Theme.of(context).secondaryHeaderColor,
        child: Padding(
          padding: const EdgeInsets.all(_paddingEdgeInsets),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add items',
                style: TextStyle(
                  fontSize: _headerTextFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              smallSpace(),
              Form(
                key: _addFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _addMakeTextController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Make',
                      ),
                      validator: (v) =>
                          v!.trim().isNotEmpty ? null : 'Need car make',
                    ),
                    smallSpace(),
                    TextFormField(
                      controller: _addModelTextController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Model',
                      ),
                      validator: (v) =>
                          v!.trim().isNotEmpty ? null : 'Need car model',
                    ),
                    smallSpace(),
                    TextFormField(
                      controller: _addKiloTextController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Kilometers (optional)',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ],
                ),
              ),
              smallSpace(),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                      onPressed: () {
                        if (_addFormKey.currentState == null ||
                            !_addFormKey.currentState!.validate()) {
                          return;
                        }
                        _realmService.add(
                          _addMakeTextController.text,
                          _addModelTextController.text,
                          kilometers: int.parse(_addKiloTextController.text),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _buildQueryCard() => Card(
        color: Theme.of(context).secondaryHeaderColor,
        child: Padding(
          padding: const EdgeInsets.all(_paddingEdgeInsets),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Query cars',
                style: TextStyle(
                  fontSize: _headerTextFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              smallSpace(),
              Form(
                key: _queryFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _queryMakeTextController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Make',
                      ),
                    ),
                    smallSpace(),
                    TextFormField(
                      controller: _queryModelTextController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Model',
                      ),
                    ),
                    smallSpace(),
                    TextFormField(
                      controller: _queryKiloTextController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Kilometers (optional)',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ],
                ),
              ),
              smallSpace(),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.saved_search),
                      label: const Text('Query'),
                      onPressed: () {
                        String syntax = '';
                        if (_queryMakeTextController.text.isNotEmpty) {
                          syntax = 'make == "${_queryMakeTextController.text}"';
                        }
                        if (_queryModelTextController.text.isNotEmpty) {
                          if (syntax.isNotEmpty) {
                            syntax +=
                                ' AND model == "${_queryModelTextController.text}"';
                          } else {
                            syntax =
                                'model == "${_queryModelTextController.text}"';
                          }
                        }
                        if (_queryKiloTextController.text.isNotEmpty) {
                          if (syntax.isNotEmpty) {
                            syntax +=
                                ' AND kilometers == "${_queryKiloTextController.text}"';
                          } else {
                            syntax =
                                'kilometers == "${_queryKiloTextController.text}"';
                          }
                        }
                        final queryResult = <String>[];
                        _realmService.query(syntax).forEach((result) {
                          queryResult.add(result.toString());
                        });
                        setState(() {
                          _queryResultTextController.text =
                              queryResult.join('\n');
                        });
                      },
                    ),
                  ),
                ],
              ),
              smallSpace(),
              TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                controller: _queryResultTextController,
                readOnly: true,
                minLines: 5,
                maxLines: 10,
              ),
            ],
          ),
        ),
      );

  Widget _buildDeleteCard() => Card(
        color: Theme.of(context).secondaryHeaderColor,
        child: Padding(
          padding: const EdgeInsets.all(_paddingEdgeInsets),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Delete cars',
                style: TextStyle(
                  fontSize: _headerTextFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              smallSpace(),
              Form(
                key: _deleteFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _deleteMakeTextController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Make',
                      ),
                    ),
                    smallSpace(),
                    TextFormField(
                      controller: _deleteModelTextController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Model',
                      ),
                    ),
                    smallSpace(),
                    TextFormField(
                      controller: _deleteKiloTextController,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Kilometers (optional)'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    )
                  ],
                ),
              ),
              smallSpace(),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
                      onPressed: () {
                        String syntax = '';
                        if (_deleteMakeTextController.text.isNotEmpty) {
                          syntax =
                              'make == "${_deleteMakeTextController.text}"';
                        }
                        if (_deleteModelTextController.text.isNotEmpty) {
                          if (syntax.isNotEmpty) {
                            syntax +=
                                ' AND model == "${_deleteModelTextController.text}"';
                          } else {
                            syntax =
                                'model == "${_queryModelTextController.text}"';
                          }
                        }
                        if (_deleteKiloTextController.text.isNotEmpty) {
                          if (syntax.isNotEmpty) {
                            syntax +=
                                ' AND kilometers == "${_deleteKiloTextController.text}"';
                          } else {
                            syntax =
                                'kilometers == "${_deleteKiloTextController.text}"';
                          }
                        }
                        print(
                            'delete ${_realmService.delete(syntax) ? "success" : "failed"}');
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Scrollbar(
        controller: _pageScrollController,
        child: SingleChildScrollView(
          controller: _pageScrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildModelInfoCard(),
              _buildAddCard(),
              _buildQueryCard(),
              _buildDeleteCard(),
            ],
          ),
        ),
      ),
    );
  }
}

SizedBox smallSpace() => const SizedBox(
      width: 10,
      height: 10,
    );

class RealmService {
  final config = Configuration.local([Car.schema]);
  late final _realm = Realm(config);

  String path() => _realm.config.path;

  void add(String make, String model, {int? kilometers}) {
    try {
      _realm.write(() {
        _realm.add(
          Car(ObjectId(), make, model, kilometers: kilometers),
        );
      });
    } finally {}
  }

  List<Car> query(String querySyntax) {
    if (querySyntax.isEmpty) {
      return _realm.all<Car>().toList();
    }
    return _realm.all<Car>().query(querySyntax).toList();
  }

  bool delete(String deleteSyntax) {
    if (deleteSyntax.isEmpty) {
      return false;
    }
    final targetObjs = query(deleteSyntax);
    if (targetObjs.isEmpty) {
      return false;
    }
    _realm.write(() {
      for (final obj in targetObjs) {
        final item = _realm.find<Car>(obj.id);
        if (item == null) {
          continue;
        }
        _realm.delete<Car>(obj);
      }
    });
    return true;
  }
}
