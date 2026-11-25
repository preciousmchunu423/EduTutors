import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../viewmodels/tutor_view_model.dart';
import '../../theme/app_theme.dart';

class TutorProfileScreen extends StatefulWidget {
  const TutorProfileScreen({super.key});
  @override State<TutorProfileScreen> createState() => _TutorProfileScreenState();
}
class _TutorProfileScreenState extends State<TutorProfileScreen> {
  final _bio = TextEditingController(); final _qualifications = TextEditingController();
  final _subjects = TextEditingController(); final _rate = TextEditingController(); bool _loaded = false;
  @override void didChangeDependencies() { super.didChangeDependencies(); final vm = context.watch<TutorViewModel>(); if (vm.isReady && !_loaded) { final w=vm.workspace; _bio.text=w.bio; _qualifications.text=w.qualifications; _subjects.text=w.subjects.join(', '); _rate.text='${w.hourlyRate}'; _loaded=true; } }
  @override void dispose(){_bio.dispose();_qualifications.dispose();_subjects.dispose();_rate.dispose();super.dispose();}
  @override Widget build(BuildContext context) { final vm=context.watch<TutorViewModel>(); return Scaffold(appBar:AppBar(title:const Text('My Tutor Profile')),body:!vm.isReady?const Center(child:CircularProgressIndicator()):ListView(padding:const EdgeInsets.all(20),children:[const _Intro(icon:Icons.badge_outlined,title:'Your tutor profile',subtitle:'Help learners and parents understand what you teach.'),const SizedBox(height:20),TextField(controller:_bio,maxLines:4,decoration:const InputDecoration(labelText:'About me',hintText:'Introduce yourself and your teaching style')),const SizedBox(height:14),TextField(controller:_qualifications,maxLines:2,decoration:const InputDecoration(labelText:'Qualifications and experience')),const SizedBox(height:14),TextField(controller:_subjects,decoration:const InputDecoration(labelText:'Subjects',hintText:'Mathematics, English, Physical Sciences')),const SizedBox(height:14),TextField(controller:_rate,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Hourly rate (R)',prefixText:'R ')),const SizedBox(height:24),FilledButton.icon(onPressed:() async { final rate=int.tryParse(_rate.text.trim()); if(rate==null||rate<0){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Enter a valid hourly rate.')));return;} await context.read<TutorViewModel>().updateProfile(bio:_bio.text.trim(),qualifications:_qualifications.text.trim(),subjects:_subjects.text.split(',').map((e)=>e.trim()).where((e)=>e.isNotEmpty).toSet().toList(),hourlyRate:rate); if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Profile saved on this device.')));},icon:const Icon(Icons.save_outlined),label:const Text('Save profile'))])); }
}

class _Intro extends StatelessWidget {const _Intro({required this.icon,required this.title,required this.subtitle});final IconData icon;final String title,subtitle;@override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:AppColors.blueSoft,borderRadius:BorderRadius.circular(16)),child:Row(children:[Icon(icon,color:AppColors.blue,size:32),const SizedBox(width:14),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontSize:17,fontWeight:FontWeight.bold)),const SizedBox(height:4),Text(subtitle,style:const TextStyle(color:AppColors.textMuted))]))]));}
