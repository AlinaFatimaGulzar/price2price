import '../../showrooms/domain/showroom.dart';

abstract interface class AdminShowroomRepository {
  Future<List<Showroom>> getAllShowrooms();
  Future<List<Showroom>> searchAllShowrooms(String query);
  Future<Showroom> createShowroom(Showroom showroom);
  Future<Showroom> updateShowroom(Showroom showroom);
  Future<void> deleteShowroom(int id);
  Future<void> updateShowroomStatus(int id, String status);
  Future<void> approveShowroom(int id);
  Future<void> rejectShowroom(int id);
}
