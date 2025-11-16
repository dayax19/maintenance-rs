<?php
namespace Database\Seeders;
use Illuminate\Database\Seeder;
use App\Models\Category;
use App\Models\Room;
use App\Models\Vendor;
use App\Models\Asset;
class SampleDataSeeder extends Seeder {
    public function run() {
        $c1 = Category::create(['name'=>'Electromedik']);
        $c2 = Category::create(['name'=>'Mekanik']);
        $r1 = Room::create(['name'=>'ICU','floor'=>'1']);
        $r2 = Room::create(['name'=>'IGD','floor'=>'G']);
        $v1 = Vendor::create(['name'=>'PT Medika','contact_person'=>'Budi','phone'=>'08123456789']);
        Asset::create(['asset_code'=>'AS-ECG-001','name'=>'ECG Machine','category_id'=>$c1->id,'room_id'=>$r1->id,'vendor_id'=>$v1->id,'serial_number'=>'ECG-123','pm_interval_days'=>90]);
        Asset::create(['asset_code'=>'AS-OXY-001','name'=>'Oxygen Manifold','category_id'=>$c2->id,'room_id'=>$r2->id,'vendor_id'=>$v1->id,'serial_number'=>'OXY-001','pm_interval_days'=>30]);
    }
}
