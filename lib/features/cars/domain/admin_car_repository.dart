import '../../showrooms/domain/showroom.dart';
import 'car.dart';

abstract interface class AdminCarRepository {
  Future<List<Car>> getAllCars();
  Future<List<Car>> getCarsForShowroom(int showroomId);
  Future<List<Car>> searchAllCars(String query);
  Future<Car> createCar(Car car);
  Future<Car> updateCar(Car car);
  Future<void> deleteCar(int id);
  Future<void> updateCarStatus(int id, String status);
  Future<void> approveCar(int id);
  Future<void> rejectCar(int id);
  Future<List<Showroom>> getShowroomsForDropdown();
}
