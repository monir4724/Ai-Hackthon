<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('scam_patterns', function (Blueprint $table) {
            $table->string('location_label', 120)->nullable()->after('text_bn');
        });
    }

    public function down(): void
    {
        Schema::table('scam_patterns', function (Blueprint $table) {
            $table->dropColumn('location_label');
        });
    }
};
