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
