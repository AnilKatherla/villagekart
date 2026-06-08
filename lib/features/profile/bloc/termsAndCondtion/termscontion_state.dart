import '../../model/aboutus_model.dart';

abstract class TermsState {}

class TermsInitial extends TermsState {}

class TermsLoading extends TermsState {}

// class TermsLoaded extends TermsState {
//  final List<AppContentLink> links;

//   TermsLoaded(this.links);
// }

class TermsError extends TermsState {
  final String errorMessage;

  TermsError(this.errorMessage);
}
