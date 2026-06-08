// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:villag_kart/features/profile/model/aboutus_model.dart';
// import '../aboutus_page/aboutus_service.dart';
// import 'termscontion_event.dart';
// import 'termscontion_state.dart';


// class TermsBloc extends Bloc<TermsEvent, TermsState> {
//   final AppContentLinksService _service;

//   TermsBloc({AppContentLinksService? service})
//       : _service = service ?? AppContentLinksService(),
//         super(TermsInitial()) {
//     on<FetchTermsContentLinks>(_onFetchTermsContentLinks);
//   }

//   Future<void> _onFetchTermsContentLinks(
//     FetchTermsContentLinks event,
//     Emitter<TermsState> emit,
//   ) async {
//     emit(TermsLoading());
    
//     try {
//       // Fetch the response from the service
//       final response = await _service.fetchAppContentLinks();
      
//       // Access the links from response.data.links
//       //emit(TermsLoaded(response.data.links));
//     } catch (e) {
//       emit(TermsError(e.toString()));
//     }
//   }
// }