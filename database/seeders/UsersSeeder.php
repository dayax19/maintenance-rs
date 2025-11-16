<?php
namespace Database\Seeders;
use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
class UsersSeeder extends Seeder {
    public function run() {
        User::create(['name'=>'Admin RS','email'=>'admin@rs.local','password'=>Hash::make('password'),'role'=>'admin']);
        User::create(['name'=>'Teknisi A','email'=>'tech1@rs.local','password'=>Hash::make('password'),'role'=>'technician']);
        User::create(['name'=>'Teknisi B','email'=>'tech2@rs.local','password'=>Hash::make('password'),'role'=>'technician']);
    }
}
