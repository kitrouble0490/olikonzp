<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $request->validate([
            'login' => 'required|string',
            'password' => 'required|string',
        ]);

        // Пытаемся найти пользователя по email (используем email как login)
        // Если логин не содержит @, добавляем @olikon.local
        $email = $request->login;
        if (strpos($email, '@') === false) {
            $email = $email . '@olikon.local';
        }
        
        $credentials = [
            'email' => $email,
            'password' => $request->password,
        ];

        if (Auth::attempt($credentials, $request->boolean('remember'))) {
            $request->session()->regenerate();

            return response()->json([
                'success' => true,
                'user' => Auth::user(),
            ]);
        }

        throw ValidationException::withMessages([
            'login' => ['Неверный логин или пароль.'],
        ]);
    }

    public function logout(Request $request)
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return response()->json([
            'success' => true,
            'message' => 'Вы успешно вышли из системы',
        ]);
    }

    public function check(Request $request)
    {
        return response()->json([
            'authenticated' => Auth::check(),
            'user' => Auth::user(),
        ]);
    }
}
