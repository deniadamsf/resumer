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
        Schema::create('cv_profiles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->unsignedTinyInteger('profile_index')->default(1); // 1, 2, or 3
            $table->string('title')->default('CV 1');
            $table->string('target_job')->nullable();
            $table->string('template_id')->default('asian_ats'); // asian_ats, western_strict, modern_accent
            $table->string('font_family')->default('Outfit'); // Calibri, Arial, Garamond, Outfit
            $table->string('accent_color')->default('#0B132B'); // Midnight Oxford Navy (#0B132B), etc.
            $table->json('cv_data'); // Structured modular JSON data (~2-5KB)
            $table->unsignedTinyInteger('ats_score')->nullable();
            $table->timestamps();

            $table->unique(['user_id', 'profile_index']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('cv_profiles');
    }
};
