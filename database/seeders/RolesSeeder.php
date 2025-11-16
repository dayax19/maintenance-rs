<?php
namespace Database\Seeders;
use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Role;
class RolesSeeder extends Seeder {
    public function run() {
        Role::firstOrCreate(['name'=>'admin']);
        Role::firstOrCreate(['name'=>'technician']);
        Role::firstOrCreate(['name'=>'supervisor']);
    }
}
