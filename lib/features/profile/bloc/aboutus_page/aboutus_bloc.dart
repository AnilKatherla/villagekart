import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:villag_kart/features/profile/bloc/aboutus_page/aboutus_event.dart';
import 'package:villag_kart/features/profile/bloc/aboutus_page/aboutus_state.dart';
import 'package:villag_kart/features/profile/model/aboutus_model.dart';

class AboutusBloc extends Bloc<AboutusEvent,AboutusState>{
  AboutusBloc() : super(AboutusInitial()){
    on<LoadAboutusEvent>(_onLoadAbout);
  }

  Future<void>_onLoadAbout(
    LoadAboutusEvent event,
    Emitter<AboutusState>emit,
  )async{
    emit(Aboutusloading());
    await Future.delayed(const Duration(seconds:1));
    try{
      final about = AboutusModel(
        logo: 'assets/images/villagekart_logo.svg',
        caption: 'Fill your kitchen needs\nfrom your favourite store',
        image: 'assets/images/aboutUslogo.svg',
        text1: '''About Us - Villag Kart

Villag Kart is a specialized e-commerce platform dedicated to serving rural communities across India with convenient grocery delivery services.Our Mission
To bridge the gap between rural villages and modern shopping convenience by providing scheduled delivery of groceries and daily essentials directly to village doorsteps.''', 

        text2: '''What We Offer
• Fresh Fruits & Vegetables – Daily handpicked produce
• Groceries & Essentials – Complete range of household necessities
• Scheduled Delivery – Reliable, time-specific delivery system
• Local Products – Regional specialties and traditional items
• Multiple Categories – From dairy and spices to baby care products''', 

        text3: '''Why Choose Us
✓ Village-First Design – Built specifically for rural communities
✓ Scheduled Deliveries – Predictable service that fits your schedule
✓ Quality Assurance – Fresh, premium products at affordable prices
✓ Easy Ordering – Works even with limited connectivity
✓ Local Support – Customer service in regional languages
✓ Flexible Payment – Cash-on-delivery and digital payments

Our Promise
Making quality groceries accessible to every rural household.

Developed and Maintained by VillagKart Pvt. Ltd.
Connecting Villages, Delivering Convenience''', 
        address: '8-2-415, 1-5, Rd Number 4, Green Valley, \nBanjara Hills, Hyderabad, Telangana 500034');
        emit(AboutusLoaded(about));
    }catch(e){
      emit(AboutusError(e.toString()));
    }
  }
}