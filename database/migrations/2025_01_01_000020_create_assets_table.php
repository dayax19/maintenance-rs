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
