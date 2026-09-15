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
        Schema::create('daily_quotas', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->constrained('users')->cascadeOnDelete();
            $table->string('device_uuid')->index();
            $table->date('quota_date')->index();
            $table->unsignedTinyInteger('used_count')->default(0);
            $table->timestamp('last_request_at')->nullable();
            $table->timestamps();

            $table->unique(['device_uuid', 'quota_date']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('daily_quotas');
    }
};
