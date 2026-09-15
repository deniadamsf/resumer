<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('ats_histories', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->constrained('users')->cascadeOnDelete();
            $table->string('device_uuid')->index();
            $table->foreignId('cv_profile_id')->nullable()->constrained('cv_profiles')->nullOnDelete();
            $table->unsignedTinyInteger('score'); // 0 - 100
            $table->json('breakdown'); // keyword_match, impact_verbs, readability, completeness
            $table->json('actionable_feedback'); // list of concrete improvement recommendations
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('ats_histories');
    }
};
