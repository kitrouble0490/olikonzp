<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Создаем начального пользователя
        // Логин: olikon, Пароль: 11592309
        User::firstOrCreate(
            ['email' => 'olikon@olikon.local'],
            [
                'name' => 'Olikon',
                'email' => 'olikon@olikon.local',
                'password' => bcrypt('11592309'),
            ]
        );
    }
}
