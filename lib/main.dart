import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/household_accounts_page.dart';
import 'screens/maintenance_records_page.dart';
import 'screens/maintenance_schedule_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //20240519_deleta_Vercel.json対応
  //.envファイルを読み込む設定.
  await dotenv.load(fileName: 'env');

  // Supabaseを初期化. .envファイルからURLとanonKeyを取得して設定.
  await Supabase.initialize(
    url: dotenv.get('VAR_URL'),
    anonKey: dotenv.get('VAR_ANONKEY'),
  );
  //eof_20240519_deleta_Vercel.json対応

  // Flutterアプリを起動.
  runApp(const FlutterTestApp());
}

// メインのFlutterアプリケーションクラス.
class FlutterTestApp extends StatelessWidget {
  const FlutterTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home',
      // 20240519_002_Vercel.json対応
      home: const HomePage(),  // ホーム画面としてHomePageを指定.
    );
  }
}

// HomePageクラスとその状態管理クラス.
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Supabaseのストリームを設定してデータベースの変更をリアルタイムで監視.
  final _carMaintenanceStream = Supabase.instance.client
      .from('t_car_maintenance')
      .stream(primaryKey: ['id']);

  // フォームの入力値を保存するためのコントローラー.
  // final TextEditingController _body = TextEditingController();
  
  // フォームの入力値を保存するためのコントローラー.（追加対応）
  final TextEditingController _bodyController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _inputDateController = TextEditingController();
  bool _isDone = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
      ),

      // drawerのコードを追加
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: const Text('家計簿'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HouseholdAccountsPage()),
                );
              },
            ),
            ListTile(
              title: const Text('メンテ実績登録'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MaintenanceRecordsPage()),
                );
              },
            ),
            ListTile(
              title: const Text('メンテ予定登録'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MaintenanceSchedulePage()),
                );
              },
            ),
          ],
        ),
      ),



      // StreamBuilderを使用してリアルタイムでデータの変更を反映.
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _carMaintenanceStream,
        builder: (context, snapshot) {
          // データがまだ読み込まれていない場合、プログレスインジケーターを表示.
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // 取得したデータをリストで表示.
          final carMaintenance = snapshot.data!;

          return ListView.builder(
            itemCount: carMaintenance.length,
            itemBuilder: (context, index) {
              final item = carMaintenance[index];
              final body = item['content'] as String?;
              final createdAt = item['created_at'] as String?;

              return ListTile(
                trailing: SizedBox(
                  width: 100,
                  child: Row(
                    children: [
                      // 編集ボタン
                      IconButton(
                        onPressed: () async {
                          // ダイアログを表示してノートの編集を行う.
                          showDialog(
                            context: context,
                            builder: (context) {
                              return SimpleDialog(
                                title: const Text('Add a Note'),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                                children: [
                                  TextFormField(
                                    controller: _bodyController,  // 入力フォームのコントローラーを設定.
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      // データベースの内容を更新する処理.
                                      await Supabase.instance.client
                                          .from('t_car_maintenance')
                                          .update({'content': _bodyController.text})
                                          .match({'id': item['id']});
                                      Navigator.of(context).pop();  // ダイアログを閉じる.
                                    },
                                    child: const Text('Put'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.blueAccent,
                        ),
                      ),
                       // 削除ボタン
                      IconButton(
                        onPressed: () async {
                          // 確認ダイアログを表示.
                          bool? confirmDelete = await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Confirm Delete'),
                                content: const Text('Are you sure you want to delete this item?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(false);  // 削除をキャンセル.
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(true);  // 削除を確認.
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirmDelete == true) {
                            // 選択したアイテムをデータベースから削除する処理.
                            await Supabase.instance.client
                                .from('t_car_maintenance')
                                .delete()
                                .match({'id': item['id']});
                          }
                        },
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                    //   // 削除ボタン
                    //   IconButton(
                    //     onPressed: () async {
                    //       // 選択したアイテムをデータベースから削除する処理.
                    //       await Supabase.instance.client
                    //           .from('t_car_maintenance')
                    //           .delete()
                    //           .match({'id': item['id']});
                    //     },
                    //     icon: const Icon(
                    //       Icons.delete,
                    //       color: Colors.redAccent,
                    //     ),
                    //   ),
                    // ],
                  ),
                ),
                title: Text(body ?? 'No body'), // ノートの内容を表示.
                subtitle: Text(createdAt ?? 'No date'), // 作成された日時を表示.
              );
            },
          );
        },
      ),


      // 追加ボタン
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // ダイアログを表示して新しいノートを追加する処理.
          showDialog(
            context: context,
            builder: (context) {
              return SimpleDialog(
                title: const Text('Add a Note'),
                contentPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                children: [
                  TextFormField(
                    controller: _bodyController,  // 入力フォームのコントローラーを設定.
                    decoration: const InputDecoration(labelText: 'Content'),
                  ),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _inputDateController,
                    decoration: const InputDecoration(labelText: 'Input Date (YYYY-MM-DD)'),
                    keyboardType: TextInputType.datetime,
                  ),
                  CheckboxListTile(
                    title: const Text('Is Done'),
                    value: _isDone,
                    onChanged: (bool? value) {
                      setState(() {
                        _isDone = value ?? false;
                      });
                    },
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // 新しいノートをデータベースに追加する処理.
                      await Supabase.instance.client
                          .from('t_car_maintenance')
                          .insert({
                            'content': _bodyController.text,
                            'price': int.parse(_priceController.text),
                            'is_done': _isDone,
                            'input_date': _inputDateController.text,
                          });
                      Navigator.of(context).pop();  // ダイアログを閉じる.
                    },
                    child: const Text('Post'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
