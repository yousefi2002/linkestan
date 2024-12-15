import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:linkestan/databaseHelper/urgent_numbers_m.dart';
import 'package:linkestan/urgent_numbers_page/urgent_bloc.dart';
import 'package:linkestan/urgent_numbers_page/urgent_event.dart';
import 'package:linkestan/urgent_numbers_page/urgent_state.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main_page/app_localozation.dart';
import '../my_constants.dart';
import '../visit_card_related_pages/visit_cards.dart';

class FavoriteUrgentNumbers extends StatefulWidget {
  const FavoriteUrgentNumbers({super.key});

  @override
  _FavoriteUrgentNumbersState createState() => _FavoriteUrgentNumbersState();
}

class _FavoriteUrgentNumbersState extends State<FavoriteUrgentNumbers> {
  final List<UrgentNumberMap> favoriteItems = [];

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.favorite, color: Colors.red),
            Text(AppLocalizations.of(context).translate('favorite_urgent_numbers')),
          ],
        ),
      ),
      body: BlocBuilder<FavoriteUrgentBloc, FavoriteUrgentState>(
          builder: (context, state) {
            if (state is FavoriteUrgentLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is FavoriteUrgentLoaded) {
              final favoriteUrgent =
              state.urgent.where((visitCard) => visitCard.favorite == 1).toList();

              if (favoriteUrgent.isEmpty) {
                return Center(
                  child: Text(
                    AppLocalizations.of(context).translate('not_found'),
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: favoriteUrgent.length,
                itemBuilder: (context, index) {
                  final urgent = favoriteUrgent[index];
                  return Padding(
                    padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
                    child: ListTile(
                      title: Text(urgent.numberName),
                      subtitle: Text(urgent.number),
                      shape: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide(color: Colors.green.shade800, width: 2),
                      ),
                      leading: CircleAvatar(
                        foregroundColor: Colors.green.shade800,
                        backgroundColor: Colors.white,
                        child: Text(urgent.numberName[0]),
                      ),
                      onTap: () {
                        showDialog(context: context,
                            builder: (context) => detailDialog(context, urgent.description));
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              context.read<FavoriteUrgentBloc>()
                                  .add(ToggleFavoriteUrgentEvent(urgent));
                            },
                            icon: Icon(
                              urgent.favorite == 1 ? Icons.favorite :
                              Icons.favorite_border,
                              color: Colors.red,
                            ),
                          ),
                          if(urgent.type == 'my choice')
                            IconButton(onPressed: (){
                              showDialog(context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(AppLocalizations.of(context).translate('warning'), textAlign: TextAlign.center,),
                                    titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                                    content: Text(AppLocalizations.of(context).translate('delete_un'), textAlign: TextAlign.center,),
                                    contentTextStyle: TextStyle(color: Colors.green.shade800),
                                    actions: [
                                      ElevatedButton(onPressed: (){
                                        context.read<FavoriteUrgentBloc>().add(DeleteUrgentEvent(urgent));
                                        Navigator.pop(context);
                                      }, child: const Icon(Icons.check)),
                                      ElevatedButton(
                                        onPressed: (){
                                          Navigator.pop(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red),
                                        child: const Icon(Icons.close),),
                                    ],
                                    backgroundColor: lightGreen,
                                    actionsAlignment: MainAxisAlignment.center,
                                  ));
                            }, icon: const Icon(Icons.delete, color: Colors.red,)),
                          IconButton(
                            onPressed: () {
                              _makePhoneCall(urgent.number);
                            },
                            icon: const Icon(
                              Icons.phone,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else if (state is FavoriteUrgentError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            } else {
              return const Center(child: Text('Unexpected state.'));
            }
          }),
    );
  }
}
