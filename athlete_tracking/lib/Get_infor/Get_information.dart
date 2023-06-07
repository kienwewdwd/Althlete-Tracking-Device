import 'package:athlete_tracking/Screens/home_Screen.dart';
import 'package:athlete_tracking/constrants.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:athlete_tracking/Screens/background.dart';

class HomePage11 extends StatefulWidget {
  const HomePage11({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage11> {
// text fields' controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _sexController = TextEditingController();

  final CollectionReference _users =
      FirebaseFirestore.instance.collection('users');

  Future<void> _create([DocumentSnapshot? documentSnapshot]) async {
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 50),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    style: TextStyle(fontWeight: FontWeight.bold),
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    style: TextStyle(fontWeight: FontWeight.bold),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    controller: _ageController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your age',
                      labelText: 'Age',
                    ),
                  ),
                  TextField(
                    style: TextStyle(fontWeight: FontWeight.bold),
                    controller: _sexController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your sex',
                      labelText: 'Sex',
                    ),
                  ),
                  TextField(
                    style: TextStyle(fontWeight: FontWeight.bold),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    controller: _heightController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your height',
                      labelText: 'Height(cm)',
                    ),
                  ),
                  TextField(
                    style: TextStyle(fontWeight: FontWeight.bold),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    controller: _weightController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your weight',
                      labelText: 'Weight(kg)',
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: FloatingActionButton(
                      backgroundColor: CustomColors.kPrimaryColor,
                      child: const Icon(Icons.create_new_folder),
                      onPressed: () async {
                        final String name = _nameController.text;

                        final double? age =
                            double.tryParse(_ageController.text);
                        final double? height =
                            double.tryParse(_heightController.text);
                        final double? weight =
                            double.tryParse(_weightController.text);
                        final String sex = _sexController.text;

                        if (age != null && height != null && weight != null) {
                          await _users.add({
                            "name": name,
                            "age": age,
                            "sex": sex,
                            "weight": weight,
                            "height": height,
                            "BMI": (weight / ((height / 100) * (height / 100)))
                                .toStringAsFixed(2),
                          });

                          _nameController.text = '';
                          _ageController.text = '';
                          _sexController.text = '';
                          _weightController.text = '';
                          _heightController.text = '';

                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  Future<void> _update([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {
      _nameController.text = documentSnapshot['name'];
      _ageController.text = documentSnapshot['age'].toString();
      _sexController.text = documentSnapshot['sex'];
      _weightController.text = documentSnapshot['weight'].toString();
      _heightController.text = documentSnapshot['height'].toString();
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    style: TextStyle(fontWeight: FontWeight.bold),
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    style: TextStyle(fontWeight: FontWeight.bold),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    controller: _ageController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your age',
                      labelText: 'Age',
                    ),
                  ),
                  TextField(
                    style: TextStyle(fontWeight: FontWeight.bold),
                    controller: _sexController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your sex',
                      labelText: 'Sex',
                    ),
                  ),
                  TextField(
                    style: TextStyle(fontWeight: FontWeight.bold),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    controller: _heightController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your height',
                      labelText: 'Height(cm)',
                    ),
                  ),
                  TextField(
                    style: TextStyle(fontWeight: FontWeight.bold),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    controller: _weightController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your weight',
                      labelText: 'Weight(kg)',
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: FloatingActionButton(
                      backgroundColor: CustomColors.kPrimaryColor,
                      child: const Icon(Icons.edit),
                      onPressed: () async {
                        final String name = _nameController.text;

                        final double? age =
                            double.tryParse(_ageController.text);
                        final double? height =
                            double.tryParse(_heightController.text);
                        final double? weight =
                            double.tryParse(_weightController.text);
                        final String sex = _sexController.text;
                        if (age != null && height != null && weight != null) {
                          await _users.doc(documentSnapshot!.id).update({
                            "name": name,
                            "age": age,
                            "sex": sex,
                            "weight": weight,
                            "height": height,
                            "BMI": (weight / ((height / 100) * (height / 100)))
                                .toStringAsFixed(2),
                          });
                          _nameController.text = '';

                          _ageController.text = '';
                          _sexController.text = '';
                          _weightController.text = '';
                          _heightController.text = '';
                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  Future<void> _delete(String productId) async {
    await _users.doc(productId).delete();

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You have successfully deleted a account')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new,
                  color: CustomColors.kPrimaryColor, size: 30),
              onPressed: () {
                Navigator.pop(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const OnBoardingPage()),
                );
              }),
          title: Row(
            children: [
              // const Icon(
              //   Icons.arrow_circle_down_rounded,
              //   color: CustomColors.kPrimaryColor,
              //   size: 35,
              // ),
              // SizedBox(
              //   width: 7,
              // ),
              Text(
                "        Get Information",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: CustomColors.kPrimaryColor,
                    fontSize: 25),
              ),
            ],
          ),
          centerTitle: true,
        ),
        body: StreamBuilder(
          stream: _users.snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
            if (streamSnapshot.hasData) {
              return ListView.builder(
                itemCount: streamSnapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot documentSnapshot =
                      streamSnapshot.data!.docs[index];
                  double bmi = documentSnapshot['weight'] /
                      ((documentSnapshot['height'] / 100) *
                          (documentSnapshot['height'] / 100));
                  return Card(
                    child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Container(
                            height: 130,
                            width: 100,
                            decoration: BoxDecoration(
                                color: CustomColors.kPrimaryColor,
                                borderRadius: BorderRadius.circular(50)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  margin: EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      FloatingActionButton(
                                        heroTag: null,
                                        backgroundColor: Colors.transparent,
                                        child: SvgPicture.asset(
                                          'Images/assets/icons/account.svg',
                                          height: 100,
                                          width: 100,
                                          color: CustomColors.kLightColor,
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    HomeScreen(
                                                      value: documentSnapshot[
                                                          'name'],
                                                      value2: bmi,
                                                      value3: documentSnapshot[
                                                              'age']
                                                          .toString(),
                                                      value4: documentSnapshot[
                                                          'sex'],
                                                      value5: documentSnapshot[
                                                              'height']
                                                          .toString(),
                                                      value6: documentSnapshot[
                                                              'weight']
                                                          .toString(),
                                                    )),
                                          );
                                        },
                                      ),
                                      Container(
                                        margin: EdgeInsets.all(10),
                                        child: Text(
                                          documentSnapshot['name'],
                                          style:
                                              CustomTextStyle.metricTextStyle,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.all(17),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Age: ${documentSnapshot['age'].toString()}',
                                        style: TextStyle(
                                          color: CustomColors.kLightColor,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      Text(
                                        'Sex:  ${documentSnapshot['sex']}',
                                        style: TextStyle(
                                          color: CustomColors.kLightColor,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      Text(
                                        'Height: ${documentSnapshot['height'].toString()}',
                                        style: TextStyle(
                                          color: CustomColors.kLightColor,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      Text(
                                        'Weight: ${documentSnapshot['weight'].toString()}',
                                        style: TextStyle(
                                          color: CustomColors.kLightColor,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      Text(
                                        'BMi: ${bmi.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: CustomColors.kLightColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                IconButton(
                                    icon: const Icon(Icons.edit,
                                        size: 30,
                                        color: CustomColors.kLightColor),
                                    onPressed: () => _update(documentSnapshot)),
                                IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      size: 30,
                                      color: CustomColors.kLightColor,
                                    ),
                                    onPressed: () =>
                                        _delete(documentSnapshot.id)),
                              ],
                            ))),
                  );
                },
              );
            }
            ;

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
// Add new product
        floatingActionButton: FloatingActionButton(
          backgroundColor: CustomColors.kPrimaryColor,
          onPressed: () => _create(),
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat);
  }
}
