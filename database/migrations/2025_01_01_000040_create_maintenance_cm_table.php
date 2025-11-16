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
