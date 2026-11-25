import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/booking.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../viewmodels/booking_view_model.dart';
import '../../theme/app_theme.dart';

class TutorLiveSessionsScreen extends StatelessWidget {const TutorLiveSessionsScreen({super.key});
@override Widget build(BuildContext context){final auth=context.watch<AuthViewModel>();final sessions=context.watch<BookingViewModel>().forTutor(auth.userName).where((b)=>b.status==BookingStatus.upcoming).toList();return Scaffold(appBar:AppBar(title:const Text('Live Sessions')),body:sessions.isEmpty?const Center(child:Padding(padding:EdgeInsets.all(24),child:Column(mainAxisSize:MainAxisSize.min,children:[Icon(Icons.video_call_outlined,size:56,color:AppColors.blue),SizedBox(height:12),Text('No upcoming sessions',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold)),SizedBox(height:6),Text('Your booked tutoring sessions will appear here.',textAlign:TextAlign.center,style:TextStyle(color:AppColors.textMuted))]))):ListView(padding:const EdgeInsets.all(16),children:sessions.map((b)=>Card(child:ListTile(leading:const CircleAvatar(backgroundColor:AppColors.blueSoft,child:Icon(Icons.video_camera_front_outlined,color:AppColors.blue)),title:Text(b.subject,style:const TextStyle(fontWeight:FontWeight.w700)),subtitle:Text('${b.learnerName}\n${formatDate(b.start)} • ${formatRange(b)}'),isThreeLine:true,trailing:const Icon(Icons.event_available,color:AppColors.blue),onTap:()=>showDialog(context:context,builder:(ctx)=>AlertDialog(title:const Text('Session details'),content:Text('Learner: ${b.learnerName}\nSubject: ${b.subject}\nDate: ${formatDate(b.start)}\nTime: ${formatRange(b)}\n\nA video meeting link is not configured yet.'),actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('Close'))]))))).toList()));}
}
