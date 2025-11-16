#!/usr/bin/env bash
# generate_maintenance_full.sh
# Full scaffold + optional auto-install for Maintenance RS (Laravel 11 scaffold + Flutter stub)
# - Creates migrations/models/controllers/seeders/views/mobile stubs
# - Optionally creates MySQL database + user (defaults to maintenance_rs)
# - Optionally runs composer/npm/flutter actions
#
# Usage:
#   1) Place file in root of your Laravel project (where artisan exists)
#   2) chmod +x generate_maintenance_full.sh
#   3) ./generate_maintenance_full.sh
#
# IMPORTANT:
# - Backup / commit before run. Script may overwrite files in the project.
# - If you run DB-creation prompts, you must provide MySQL root credentials that can create DB/users.
# - This script assumes mysql CLI is available at `mysql`.
set -euo pipefail

ROOT="$(pwd)"
ARTISAN="$ROOT/artisan"

if [ ! -f "$ARTISAN" ]; then
  echo "Error: artisan not found. Jalankan script ini di root project Laravel (tempat file artisan berada)."
  echo "Atau buat project baru: composer create-project laravel/laravel maintenance-rs \"11.*\""
  exit 1
fi

echo "================================================================="
echo "MAINTENANCE RS — Full scaffold + optional auto-install"
echo "Lokasi: $ROOT"
echo "Backup / commit ke git sebelum melanjutkan!"
echo "================================================================="

read -p "Lanjutkan dan buat file scaffold? (y/N) " proceed
if [[ "${proceed,,}" != "y" ]]; then
  echo "Dibatalkan."
  exit 0
fi

# === USER CONFIGURATION ===
read -p "Nama database yang ingin dibuat / digunakan [maintenance_rs]: " DB_NAME
DB_NAME=${DB_NAME:-maintenance_rs}

read -p "Buat DB baru jika belum ada? (y/N) " CREATE_DB
CREATE_DB=${CREATE_DB:-n}

if [[ "${CREATE_DB,,}" == "y" ]]; then
  read -p "MySQL root user [root]: " MYSQL_ROOT_USER
  MYSQL_ROOT_USER=${MYSQL_ROOT_USER:-root}
  # prompt password (silent)
  read -s -p "Password MySQL root (kosong jika tidak ada): " MYSQL_ROOT_PASS
  echo
fi

read -p "Buat user DB baru (recommended) ? (y/N) " CREATE_DB_USER
CREATE_DB_USER=${CREATE_DB_USER:-n}

if [[ "${CREATE_DB_USER,,}" == "y" ]]; then
  read -p "Nama DB user yang akan dibuat [rs_user]: " DB_USER
  DB_USER=${DB_USER:-rs_user}
  read -s -p "Password untuk DB user '$DB_USER': " DB_USER_PASS
  echo
fi

read -p "Apakah .env harus diupdate otomatis menggunakan DB di atas? (y/N) " UPDATE_ENV
UPDATE_ENV=${UPDATE_ENV:-n}

# Paths create
mkdir -p database/migrations database/seeders app/Models app/Http/Controllers/Api resources/views resources/views/layouts resources/css mobile/lib/pages mobile/lib/services sql

echo "Menulis file-file scaffold..."

# --- Migrations & files (same scaffolds from earlier) ---
# (for brevity: this block writes the migrations/models/controllers/seeders/views/mobile/sql)
# You can inspect/update file contents later as needed.

# USERS migration
cat > database/migrations/2025_01_01_000000_create_users_table.php <<'PHP'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
    public function up() {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('email')->unique();
            $table->timestamp('email_verified_at')->nullable();
            $table->string('password');
            $table->string('phone')->nullable();
            $table->string('role')->nullable();
            $table->rememberToken();
            $table->timestamps();
        });
    }
    public function down() {
        Schema::dropIfExists('users');
    }
};
PHP

# Asset related tables
cat > database/migrations/2025_01_01_000010_create_asset_related_tables.php <<'PHP'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
    public function up() {
        Schema::create('categories', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->timestamps();
        });
        Schema::create('rooms', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('floor')->nullable();
            $table->timestamps();
        });
        Schema::create('vendors', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('contact_person')->nullable();
            $table->string('phone')->nullable();
            $table->string('email')->nullable();
            $table->timestamps();
        });
    }
    public function down() {
        Schema::dropIfExists('vendors');
        Schema::dropIfExists('rooms');
        Schema::dropIfExists('categories');
    }
};
PHP

# Assets migration
cat > database/migrations/2025_01_01_000020_create_assets_table.php <<'PHP'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
    public function up() {
        Schema::create('assets', function (Blueprint $table) {
            $table->id();
            $table->string('asset_code')->unique();
            $table->string('name');
            $table->foreignId('category_id')->nullable()->constrained('categories')->nullOnDelete();
            $table->foreignId('room_id')->nullable()->constrained('rooms')->nullOnDelete();
            $table->foreignId('vendor_id')->nullable()->constrained('vendors')->nullOnDelete();
            $table->string('serial_number')->nullable();
            $table->date('acquisition_date')->nullable();
            $table->integer('pm_interval_days')->default(90);
            $table->date('last_pm_date')->nullable();
            $table->integer('calibration_interval_days')->default(365);
            $table->date('last_calibration_date')->nullable();
            $table->string('qr_code')->nullable();
            $table->text('manual_file')->nullable();
            $table->timestamps();
        });
    }
    public function down() {
        Schema::dropIfExists('assets');
    }
};
PHP

# PM migration
cat > database/migrations/2025_01_01_000030_create_maintenance_pm_table.php <<'PHP'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
    public function up() {
        Schema::create('maintenance_pm', function (Blueprint $table) {
            $table->id();
            $table->foreignId('asset_id')->constrained('assets')->cascadeOnDelete();
            $table->string('ticket_code')->unique();
            $table->date('scheduled_date')->nullable();
            $table->date('due_date')->nullable();
            $table->foreignId('assigned_technician')->nullable()->constrained('users')->nullOnDelete();
            $table->string('status')->default('pending');
            $table->json('checklist')->nullable();
            $table->text('notes')->nullable();
            $table->dateTime('completed_at')->nullable();
            $table->timestamps();
        });
    }
    public function down() {
        Schema::dropIfExists('maintenance_pm');
    }
};
PHP

# CM migration
cat > database/migrations/2025_01_01_000040_create_maintenance_cm_table.php <<'PHP'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
    public function up() {
        Schema::create('maintenance_cm', function (Blueprint $table) {
            $table->id();
            $table->foreignId('asset_id')->nullable()->constrained('assets')->nullOnDelete();
            $table->string('ticket_code')->unique();
            $table->foreignId('reported_by')->nullable()->constrained('users')->nullOnDelete();
            $table->dateTime('reported_at')->nullable();
            $table->string('priority')->default('low');
            $table->foreignId('assigned_technician')->nullable()->constrained('users')->nullOnDelete();
            $table->string('status')->default('new');
            $table->text('description')->nullable();
            $table->json('spareparts_used')->nullable();
            $table->decimal('cost_total',12,2)->default(0);
            $table->dateTime('resolved_at')->nullable();
            $table->timestamps();
        });
    }
    public function down() {
        Schema::dropIfExists('maintenance_cm');
    }
};
PHP

# Calibrations migration
cat > database/migrations/2025_01_01_000050_create_calibrations_table.php <<'PHP'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
    public function up() {
        Schema::create('calibrations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('asset_id')->constrained('assets')->cascadeOnDelete();
            $table->string('performed_by')->nullable();
            $table->date('calibration_date')->nullable();
            $table->date('expiry_date')->nullable();
            $table->text('certificate_file')->nullable();
            $table->text('notes')->nullable();
            $table->timestamps();
        });
    }
    public function down() {
        Schema::dropIfExists('calibrations');
    }
};
PHP

# Attachments migration
cat > database/migrations/2025_01_01_000060_create_attachments_table.php <<'PHP'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
    public function up() {
        Schema::create('attachments', function (Blueprint $table) {
            $table->id();
            $table->morphs('attachable');
            $table->string('filename');
            $table->string('path');
            $table->timestamps();
        });
    }
    public function down() {
        Schema::dropIfExists('attachments');
    }
};
PHP

# Models
cat > app/Models/Asset.php <<'PHP'
<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
class Asset extends Model {
    use HasFactory;
    protected $fillable = ['asset_code','name','category_id','room_id','vendor_id','serial_number','acquisition_date','pm_interval_days','last_pm_date','calibration_interval_days','last_calibration_date','qr_code','manual_file'];
    public function category(){ return $this->belongsTo(Category::class); }
    public function room(){ return $this->belongsTo(Room::class); }
    public function vendor(){ return $this->belongsTo(Vendor::class); }
    public function pms(){ return $this->hasMany(MaintenancePM::class,'asset_id'); }
    public function cms(){ return $this->hasMany(MaintenanceCM::class,'asset_id'); }
}
PHP

cat > app/Models/MaintenancePM.php <<'PHP'
<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
class MaintenancePM extends Model {
    use HasFactory;
    protected $table = 'maintenance_pm';
    protected $casts = ['checklist'=>'array'];
    protected $fillable = ['asset_id','ticket_code','scheduled_date','due_date','assigned_technician','status','checklist','notes','completed_at'];
    public function asset(){ return $this->belongsTo(Asset::class,'asset_id'); }
    public function technician(){ return $this->belongsTo(User::class,'assigned_technician'); }
}
PHP

cat > app/Models/MaintenanceCM.php <<'PHP'
<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
class MaintenanceCM extends Model {
    use HasFactory;
    protected $table = 'maintenance_cm';
    protected $casts = ['spareparts_used'=>'array'];
    protected $fillable = ['asset_id','ticket_code','reported_by','reported_at','priority','assigned_technician','status','description','spareparts_used','cost_total','resolved_at'];
    public function asset(){ return $this->belongsTo(Asset::class,'asset_id'); }
    public function reporter(){ return $this->belongsTo(User::class,'reported_by'); }
    public function technician(){ return $this->belongsTo(User::class,'assigned_technician'); }
}
PHP

cat > app/Models/Calibration.php <<'PHP'
<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
class Calibration extends Model {
    use HasFactory;
    protected $fillable=['asset_id','performed_by','calibration_date','expiry_date','certificate_file','notes'];
    public function asset(){ return $this->belongsTo(Asset::class); }
}
PHP

cat > app/Models/Attachment.php <<'PHP'
<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
class Attachment extends Model {
    use HasFactory;
    protected $fillable=['filename','path'];
    public function attachable(){ return $this->morphTo(); }
}
PHP

cat > app/Models/Category.php <<'PHP'
<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
class Category extends Model { use HasFactory; protected $fillable=['name']; }
PHP

cat > app/Models/Room.php <<'PHP'
<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
class Room extends Model { use HasFactory; protected $fillable=['name','floor']; }
PHP

cat > app/Models/Vendor.php <<'PHP'
<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
class Vendor extends Model { use HasFactory; protected $fillable=['name','contact_person','phone','email']; }
PHP

# Basic User model - only write if not present
if [ ! -f app/Models/User.php ]; then
cat > app/Models/User.php <<'PHP'
<?php
namespace App\Models;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
class User extends Authenticatable {
    use Notifiable;
    protected $fillable=['name','email','password','phone','role'];
    protected $hidden=['password','remember_token'];
}
PHP
fi

# Controllers (API)
mkdir -p app/Http/Controllers/Api
cat > app/Http/Controllers/Api/AuthController.php <<'PHP'
<?php
namespace App\Http\Controllers\Api;
use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
class AuthController extends Controller {
    public function login(Request $r){
        $r->validate(['email'=>'required','password'=>'required']);
        $user = User::where('email',$r->email)->first();
        if(!$user || !Hash::check($r->password,$user->password)){
            return response()->json(['message'=>'Invalid credentials'],401);
        }
        $token = $user->createToken('api-token')->plainTextToken;
        return response()->json(['user'=>$user,'token'=>$token]);
    }
    public function logout(Request $r){
        $r->user()->currentAccessToken()->delete();
        return response()->json(['message'=>'Logged out']);
    }
}
PHP

cat > app/Http/Controllers/Api/AssetApiController.php <<'PHP'
<?php
namespace App\Http\Controllers\Api;
use App\Http\Controllers\Controller;
use App\Models\Asset;
use Illuminate\Http\Request;
class AssetApiController extends Controller {
    public function index(Request $r){
        $q = Asset::with(['category','room','vendor'])->orderBy('id','desc');
        if($r->has('q')) $q->where('name','like','%'.$r->q.'%');
        return response()->json($q->paginate(20));
    }
    public function show($id){
        $a = Asset::with(['category','room','vendor','pms','cms'])->findOrFail($id);
        return response()->json($a);
    }
    public function store(Request $r){
        $data = $r->validate([
            'asset_code'=>'required|unique:assets,asset_code',
            'name'=>'required'
        ]);
        $asset = Asset::create($data);
        return response()->json($asset,201);
    }
}
PHP

cat > app/Http/Controllers/Api/WorkOrderApiController.php <<'PHP'
<?php
namespace App\Http\Controllers\Api;
use App\Http\Controllers\Controller;
use App\Models\MaintenanceCM;
use App\Models\MaintenancePM;
use Illuminate\Http\Request;
class WorkOrderApiController extends Controller {
    public function cms(Request $r){
        return response()->json(MaintenanceCM::with('asset','technician','reporter')->paginate(20));
    }
    public function createCm(Request $r){
        $data = $r->validate([
            'asset_id'=>'required',
            'description'=>'required',
            'priority'=>'required'
        ]);
        $data['ticket_code'] = 'CM-'.time();
        $data['reported_at'] = now();
        $cm = MaintenanceCM::create($data);
        return response()->json($cm,201);
    }
    public function completeCm(Request $r, $id){
        $cm = MaintenanceCM::findOrFail($id);
        $cm->status = 'resolved';
        $cm->resolved_at = now();
        $cm->save();
        return response()->json($cm);
    }
    public function pms(Request $r){
        return response()->json(MaintenancePM::with('asset','technician')->paginate(20));
    }
    public function createPm(Request $r){
        $data = $r->validate(['asset_id'=>'required','scheduled_date'=>'required']);
        $data['ticket_code'] = 'PM-'.time();
        $pm = MaintenancePM::create($data);
        return response()->json($pm,201);
    }
}
PHP

# API routes
cat > routes/api.php <<'PHP'
<?php
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\AssetApiController;
use App\Http\Controllers\Api\WorkOrderApiController;

Route::post('/login',[AuthController::class,'login']);
Route::middleware('auth:sanctum')->group(function(){
    Route::post('/logout',[AuthController::class,'logout']);
    Route::get('/assets',[AssetApiController::class,'index']);
    Route::get('/assets/{id}',[AssetApiController::class,'show']);
    Route::post('/assets',[AssetApiController::class,'store']);
    Route::get('/cms',[WorkOrderApiController::class,'cms']);
    Route::post('/cms',[WorkOrderApiController::class,'createCm']);
    Route::post('/cms/{id}/complete',[WorkOrderApiController::class,'completeCm']);
    Route::get('/pms',[WorkOrderApiController::class,'pms']);
    Route::post('/pms',[WorkOrderApiController::class,'createPm']);
});
PHP

# Seeders
cat > database/seeders/DatabaseSeeder.php <<'PHP'
<?php
namespace Database\Seeders;
use Illuminate\Database\Seeder;
class DatabaseSeeder extends Seeder {
    public function run() {
        $this->call([
            RolesSeeder::class,
            UsersSeeder::class,
            SampleDataSeeder::class,
        ]);
    }
}
PHP

cat > database/seeders/RolesSeeder.php <<'PHP'
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
PHP

cat > database/seeders/UsersSeeder.php <<'PHP'
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
PHP

cat > database/seeders/SampleDataSeeder.php <<'PHP'
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
PHP

# Blade views (simple placeholders)
cat > resources/views/layouts/app.blade.php <<'HTML'
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>@yield('title','Maintenance RS')</title>
  <link href="/css/app.css" rel="stylesheet">
</head>
<body class="bg-gray-50 font-sans">
  <div class="flex">
    <aside class="w-64 bg-white h-screen p-4 border-r">
      <div class="font-bold text-lg">RS Maintenance</div>
      <nav class="mt-6 space-y-2">
        <a href="/dashboard" class="block p-2 rounded hover:bg-gray-100">Dashboard</a>
        <a href="/assets" class="block p-2 rounded hover:bg-gray-100">Assets</a>
        <a href="#" class="block p-2 rounded hover:bg-gray-100">PM</a>
        <a href="#" class="block p-2 rounded hover:bg-gray-100">CM</a>
      </nav>
    </aside>
    <main class="flex-1 p-6">
      <header class="flex justify-between items-center mb-6">
        <h1 class="text-2xl font-semibold">@yield('page_title','Dashboard')</h1>
        <div class="flex items-center gap-4">
          <input class="border rounded p-2" placeholder="Search..." />
          <img src="/img/avatar.jpg" class="w-8 h-8 rounded-full" alt="avatar">
        </div>
      </header>

      @yield('content')
    </main>
  </div>
</body>
</html>
HTML

cat > resources/views/dashboard.blade.php <<'HTML'
@extends('layouts.app')
@section('page_title','Dashboard')
@section('content')
<div class="grid grid-cols-4 gap-4">
  <div class="p-4 bg-white rounded shadow">Total Assets<br><span class="text-2xl font-bold">123</span></div>
  <div class="p-4 bg-white rounded shadow">PM Due<br><span class="text-2xl font-bold text-yellow-600">12</span></div>
  <div class="p-4 bg-white rounded shadow">CM Active<br><span class="text-2xl font-bold text-red-600">5</span></div>
  <div class="p-4 bg-white rounded shadow">Technicians<br><span class="text-2xl font-bold">24</span></div>
</div>

<div class="mt-6 bg-white rounded shadow p-4">
  <h3 class="font-semibold mb-4">Latest Tickets</h3>
  <table class="w-full text-left">
    <thead>
      <tr><th>Code</th><th>Asset</th><th>Type</th><th>Assigned</th><th>Status</th></tr>
    </thead>
    <tbody>
      <tr><td>CM-00123</td><td>ECG Machine - ICU</td><td>Corrective</td><td>Rizal</td><td><span class="px-2 py-1 bg-yellow-100 text-yellow-800 rounded">On Progress</span></td></tr>
    </tbody>
  </table>
</div>
@endsection
HTML

# Mobile skeleton
cat > mobile/pubspec.yaml <<'YAML'
name: teknisi_app
description: Flutter app starter for Maintenance RS - Teknisi
version: 0.2.0
environment:
  sdk: ">=2.18.0 <3.0.0"
dependencies:
  flutter:
    sdk: flutter
  http: ^0.14.0
  flutter_secure_storage: ^7.0.0
  image_picker: ^0.8.6
  mobile_scanner: ^2.0.0
dev_dependencies:
  flutter_test:
    sdk: flutter
flutter:
  uses-material-design: true
YAML

cat > mobile/lib/main.dart <<'DART'
import 'package:flutter/material.dart';
import 'pages/login_page.dart';
void main(){ runApp(MyApp()); }
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title:'Teknisi', theme: ThemeData(useMaterial3:true), home: LoginPage());
  }
}
DART

cat > mobile/lib/services/api_service.dart <<'DART'
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;
  String? token;
  ApiService(this.baseUrl);
  void setToken(String t){ token = t; }
  Future<Map<String,dynamic>> login(String email,String password) async {
    final res = await http.post(Uri.parse('$baseUrl/api/login'), body: {'email':email,'password':password});
    return json.decode(res.body);
  }
  Future<dynamic> getAssets() async {
    final res = await http.get(Uri.parse('$baseUrl/api/assets'), headers: _headers());
    return json.decode(res.body);
  }
  Map<String,String> _headers(){
    final h = {'Accept':'application/json'};
    if(token!=null) h['Authorization'] = 'Bearer $token';
    return h;
  }
}
DART

cat > mobile/lib/pages/login_page.dart <<'DART'
import 'package:flutter/material.dart';
import 'home_page.dart';
import '../services/api_service.dart';

class LoginPage extends StatefulWidget {
  @override _LoginPageState createState() => _LoginPageState();
}
class _LoginPageState extends State<LoginPage> {
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final api = ApiService('http://10.0.2.2:8000'); // change to server IP
  bool loading=false;

  void doLogin() async {
    setState(()=>loading=true);
    final res = await api.login(emailC.text, passC.text);
    setState(()=>loading=false);
    if(res['token']!=null){
      api.setToken(res['token']);
      Navigator.pushReplacement(context, MaterialPageRoute(builder:(c)=>HomePage(api:api)));
    }else{
      showDialog(context: context, builder: (_)=>AlertDialog(title:Text('Login failed'),content:Text(res.toString())));
    }
  }

  @override Widget build(BuildContext context){
    return Scaffold(body: Padding(padding: EdgeInsets.all(20), child: Center(child: Column(mainAxisSize: MainAxisSize.min, children:[
      Text('Teknisi Login', style: TextStyle(fontSize:22,fontWeight:FontWeight.bold)),
      SizedBox(height:12),
      TextField(controller: emailC, decoration: InputDecoration(labelText:'Email')),
      TextField(controller: passC, obscureText:true, decoration: InputDecoration(labelText:'Password')),
      SizedBox(height:12),
      ElevatedButton(onPressed: loading?null:doLogin, child: loading?CircularProgressIndicator():Text('Login'))
    ]))));
  }
}
DART

# SQL schema file
cat > sql/maintenance_schema_full.sql <<'SQL'
-- Full schema + sample data
CREATE DATABASE IF NOT EXISTS maintenance_rs;
USE maintenance_rs;

CREATE TABLE users (id BIGINT PRIMARY KEY AUTO_INCREMENT, name VARCHAR(150), email VARCHAR(150), password VARCHAR(255), phone VARCHAR(50), role VARCHAR(50), created_at DATETIME, updated_at DATETIME);
CREATE TABLE categories (id INT PRIMARY KEY AUTO_INCREMENT, name VARCHAR(100));
CREATE TABLE rooms (id INT PRIMARY KEY AUTO_INCREMENT, name VARCHAR(100), floor VARCHAR(20));
CREATE TABLE vendors (id INT PRIMARY KEY AUTO_INCREMENT, name VARCHAR(150), contact_person VARCHAR(100), phone VARCHAR(50), email VARCHAR(100));
CREATE TABLE assets (id BIGINT PRIMARY KEY AUTO_INCREMENT, asset_code VARCHAR(50) UNIQUE, name VARCHAR(200), category_id INT, room_id INT, vendor_id INT, serial_number VARCHAR(100), acquisition_date DATE, pm_interval_days INT DEFAULT 90, last_pm_date DATE, calibration_interval_days INT DEFAULT 365, last_calibration_date DATE, qr_code VARCHAR(100), manual_file TEXT, created_at DATETIME, updated_at DATETIME);
CREATE TABLE maintenance_pm (id BIGINT PRIMARY KEY AUTO_INCREMENT, asset_id BIGINT, ticket_code VARCHAR(80), scheduled_date DATE, due_date DATE, assigned_technician BIGINT, status VARCHAR(30), checklist JSON, notes TEXT, completed_at DATETIME, created_at DATETIME, updated_at DATETIME);
CREATE TABLE maintenance_cm (id BIGINT PRIMARY KEY AUTO_INCREMENT, asset_id BIGINT, ticket_code VARCHAR(80), reported_by BIGINT, reported_at DATETIME, priority VARCHAR(20), assigned_technician BIGINT, status VARCHAR(30), description TEXT, spareparts_used JSON, cost_total DECIMAL(12,2), resolved_at DATETIME, created_at DATETIME, updated_at DATETIME);
CREATE TABLE calibrations (id BIGINT PRIMARY KEY AUTO_INCREMENT, asset_id BIGINT, performed_by VARCHAR(200), calibration_date DATE, expiry_date DATE, certificate_file TEXT, notes TEXT, created_at DATETIME, updated_at DATETIME);

INSERT INTO categories (name) VALUES ('Electromedik'),('Mekanik');
INSERT INTO rooms (name,floor) VALUES ('ICU','1'),('IGD','G');
INSERT INTO vendors (name,contact_person,phone,email) VALUES ('PT Medika','Budi','08123456789','medika@example.com');
INSERT INTO assets (asset_code,name,category_id,room_id,vendor_id,serial_number,acquisition_date,pm_interval_days,created_at,updated_at) VALUES ('AS-ECG-001','ECG Machine',1,1,1,'ECG-123','2022-01-01',90,NOW(),NOW()),('AS-OXY-001','Oxygen Manifold',2,2,1,'OXY-001','2023-06-01',30,NOW(),NOW());
SQL

echo "Scaffold files written."

# === Database creation & user (optional) ===
if [[ "${CREATE_DB,,}" == "y" ]]; then
  if ! command -v mysql >/dev/null 2>&1; then
    echo "mysql client tidak ditemukan. Install mysql-client atau jalankan pembuatan DB manual."
  else
    echo "Membuat database '${DB_NAME}' jika belum ada..."
    if [[ -z "${MYSQL_ROOT_PASS-}" ]]; then
      mysql -u "${MYSQL_ROOT_USER}" -e "CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    else
      mysql -u "${MYSQL_ROOT_USER}" -p"${MYSQL_ROOT_PASS}" -e "CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    fi
    echo "Database '${DB_NAME}' OK."
  fi
fi

if [[ "${CREATE_DB_USER,,}" == "y" ]]; then
  echo "Membuat DB user '${DB_USER}' dan memberikan hak pada database '${DB_NAME}'..."
  if [[ -z "${MYSQL_ROOT_PASS-}" ]]; then
    mysql -u "${MYSQL_ROOT_USER}" -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'127.0.0.1' IDENTIFIED BY '${DB_USER_PASS}'; GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'127.0.0.1'; FLUSH PRIVILEGES;"
  else
    mysql -u "${MYSQL_ROOT_USER}" -p"${MYSQL_ROOT_PASS}" -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'127.0.0.1' IDENTIFIED BY '${DB_USER_PASS}'; GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'127.0.0.1'; FLUSH PRIVILEGES;"
  fi
  echo "User '${DB_USER}' created/granted."
fi

# === Update .env if requested ===
if [[ "${UPDATE_ENV,,}" == "y" ]]; then
  echo "Mengupdate file .env..."
  if [ ! -f .env ]; then
    if [ -f .env.example ]; then
      cp .env.example .env
    else
      touch .env
    fi
  fi

  # function to replace or append key in .env
  replace_env() {
    local key="$1"
    local val="$2"
    if grep -q "^${key}=" .env; then
      sed -i "s|^${key}=.*|${key}=${val}|g" .env
    else
      echo "${key}=${val}" >> .env
    fi
  }

  # Choose DB credentials to write into .env
  if [[ "${CREATE_DB_USER,,}" == "y" ]]; then
    DB_WRITE_USER="${DB_USER}"
    DB_WRITE_PASS="${DB_USER_PASS}"
  else
    # use root with blank password if user didn't create DB user
    DB_WRITE_USER="${MYSQL_ROOT_USER:-root}"
    DB_WRITE_PASS="${MYSQL_ROOT_PASS:-}"
  fi

  replace_env "DB_CONNECTION" "mysql"
  replace_env "DB_HOST" "127.0.0.1"
  replace_env "DB_PORT" "3306"
  replace_env "DB_DATABASE" "${DB_NAME}"
  replace_env "DB_USERNAME" "${DB_WRITE_USER}"
  replace_env "DB_PASSWORD" "${DB_WRITE_PASS}"

  echo ".env updated — silakan periksa ulang (jika diperlukan edit manual)."
fi

# === Optional auto-install steps (composer/npm/flutter) ===
echo
echo "=== Opsional: jalankan perintah instalasi otomatis (composer/npm/artisan) ==="
read -p "Jalankan composer require laravel/sanctum spatie/laravel-permission? (y/N) " run_comp_require
if [[ "${run_comp_require,,}" == "y" ]]; then
  if ! command -v composer >/dev/null 2>&1; then
    echo "Composer tidak ditemukan. Install composer lalu jalankan lagi."
  else
    composer require laravel/sanctum spatie/laravel-permission
  fi
fi

read -p "Jalankan composer install sekarang? (y/N) " run_comp_install
if [[ "${run_comp_install,,}" == "y" ]]; then
  if ! command -v composer >/dev/null 2>&1; then
    echo "Composer tidak ditemukan. Install composer lalu jalankan lagi."
  else
    composer install
  fi
fi

read -p "Publish vendor files (sanctum & spatie)? (y/N) " run_vendor
if [[ "${run_vendor,,}" == "y" ]]; then
  php artisan vendor:publish --provider="Laravel\\Sanctum\\SanctumServiceProvider" --tag="migrations" || true
  php artisan vendor:publish --provider="Spatie\\Permission\\PermissionServiceProvider" --tag="migrations" || true
  php artisan vendor:publish --provider="Spatie\\Permission\\PermissionServiceProvider" --tag="config" || true
fi

read -p "Jalankan php artisan key:generate sekarang? (y/N) " run_key
if [[ "${run_key,,}" == "y" ]]; then
  php artisan key:generate
fi

read -p "Jalankan php artisan migrate --seed sekarang? (y/N) " run_migrate
if [[ "${run_migrate,,}" == "y" ]]; then
  php artisan migrate --seed
fi

read -p "Jalankan npm install && npm run dev sekarang? (y/N) " run_npm
if [[ "${run_npm,,}" == "y" ]]; then
  if ! command -v npm >/dev/null 2>&1; then
    echo "npm tidak ditemukan. Install Node.js/npm lalu jalankan lagi."
  else
    npm install
    npm run dev || npm run build || true
  fi
fi

# Flutter
if [ -d "mobile" ]; then
  read -p "Jalankan flutter pub get di folder mobile sekarang? (y/N) " run_flutter
  if [[ "${run_flutter,,}" == "y" ]]; then
    if ! command -v flutter >/dev/null 2>&1; then
      echo "flutter tidak ditemukan. Install Flutter SDK lalu jalankan lagi."
    else
      (cd mobile && flutter pub get)
    fi
  fi
fi

echo
echo "Selesai — scaffold dibuat."
echo "Periksa file .env, konfigurasi Sanctum (SANCTUM_STATEFUL_DOMAINS), dan konfigurasi Spatie (jika dipakai)."
echo "Rekomendasi langkah manual bila belum dijalankan otomatis:"
echo "  composer install"
echo "  php artisan key:generate"
echo "  php artisan vendor:publish --provider=\"Spatie\\Permission\\PermissionServiceProvider\" --tag=\"config\""
echo "  php artisan migrate --seed"
echo "  npm install && npm run dev"
echo "  cd mobile && flutter pub get"
echo
echo "Kalau ada error saat menjalankan salah satu langkah, copy-paste pesan error ke saya — saya bantu debug."
