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
