import 'enquiry.dart';

abstract interface class EnquiryRepository {
  Future<void> submitEnquiry({
    required String name,
    required String phone,
    required String message,
    int? carId,
    int? showroomId,
    String? carTitle,
    String? showroomName,
  });

  Future<List<Enquiry>> getAllEnquiries();

  Future<void> updateEnquiryStatus(int id, String status);
}
