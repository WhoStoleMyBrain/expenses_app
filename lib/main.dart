import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './widgets/transaction_list.dart';
import './widgets/new_transaction.dart';
import './models/transaction.dart';
import './widgets/chart.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setPreferredOrientations(
  //     [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Expenses',
      theme: ThemeData(
          primarySwatch: Colors.purple,
          accentColor: Colors.amber,
          fontFamily: 'Quicksand',
          buttonTheme: ButtonThemeData(
            textTheme: ButtonTextTheme.primary,
            buttonColor: Colors.white,
          ),
          textTheme: ThemeData.light().textTheme.copyWith(
                titleLarge: TextStyle(
                  fontFamily: 'OpenSans',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                displayMedium: TextStyle(color: Colors.white),
                // button: TextStyle(color: Colors.white),
              ),
          appBarTheme: AppBarTheme(
            toolbarTextStyle: ThemeData.light()
                .textTheme
                .copyWith(
                    titleLarge: TextStyle(fontFamily: 'OpenSans', fontSize: 20))
                .bodyText2,
            titleTextStyle: ThemeData.light()
                .textTheme
                .copyWith(
                    titleLarge: TextStyle(fontFamily: 'OpenSans', fontSize: 20))
                .headline6,
          )),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Transaction> _userTransaction = [];
  bool _showChart = false;

  List<Transaction> get _recentTransactions {
    return _userTransaction.where(
      (tx) {
        return tx.date.isAfter(DateTime.now().subtract(Duration(days: 7)));
      },
    ).toList();
  }

  void _addNewTransaction(
      String txTitle, double txAmount, DateTime chosenDate) {
    final newTx = Transaction(
        id: DateTime.now().toString(),
        title: txTitle,
        amount: txAmount,
        date: chosenDate);
    setState(() {
      _userTransaction.add(newTx);
      _sortTransactions();
    });
  }

  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (bCtx) {
        return GestureDetector(
          onTap: () {},
          child: NewTransaction(_addNewTransaction),
          behavior: HitTestBehavior.opaque,
        );
      },
    );
  }

  void _deleteTransaction(String id) {
    setState(() {
      _userTransaction.removeWhere((tx) => tx.id == id);
      _sortTransactions();
    });
  }

  void _sortTransactions() {
    if (_userTransaction.length > 1) {
      _userTransaction.sort(
        (a, b) {
          return -a.date.compareTo(b.date);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape =
        mediaQuery.orientation == Orientation.landscape;
    final appBar = AppBar(
      title: Text(
        'Personal Expenses',
        style: TextStyle(fontFamily: 'Open Sans'),
      ),
      actions: <Widget>[
        IconButton(
            onPressed: () => _startAddNewTransaction(context),
            icon: Icon(Icons.add)),
      ],
    );
    final txListWidget = Container(
      child: TransactionList(_userTransaction, _deleteTransaction),
      height: (mediaQuery.size.height -
              appBar.preferredSize.height -
          mediaQuery.padding.top) *
          0.7,
    );
    return Scaffold(
      appBar: appBar,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (isLandscape)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Show Chart'),
                  Switch(
                      value: _showChart,
                      onChanged: (val) {
                        setState(() {
                          _showChart = val;
                        });
                      })
                ],
              ),
            if (!isLandscape) Container(
              child: Chart(_recentTransactions),
              height: (mediaQuery.size.height -
                  appBar.preferredSize.height -
                  mediaQuery.padding.top) *
                  0.3,
            ),
            if (!isLandscape) txListWidget,
            if (isLandscape) _showChart
                ? Container(
                    child: Chart(_recentTransactions),
                    height: (mediaQuery.size.height -
                            appBar.preferredSize.height -
                        mediaQuery.padding.top) *
                        0.7,
                  )
                : txListWidget,
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _startAddNewTransaction(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
