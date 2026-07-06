<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('scam_patterns', function (Blueprint $table) {
            $table->id();
            $table->string('external_id')->nullable()->index();
            $table->string('category');
            $table->string('label');
            $table->string('risk_level');
            $table->text('text_bn');
            $table->text('red_flags_bn')->nullable();
            $table->text('pattern_basis')->nullable();
            $table->boolean('is_synthetic')->default(true);
            $table->boolean('is_community_report')->default(false);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('scam_patterns');
    }
};
