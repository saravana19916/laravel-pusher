<?php

use Illuminate\Support\Facades\Route;

use App\Events\TestEvent;

use App\Http\Controllers\StudentController;

use App\Http\Controllers\UserController;

use App\Events\StatusLiked;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

Route::get('/', function () {
    return view('welcome');
});

Route::get('test', [StudentController::class, 'index']);

Route::resource('users', UserController::class);

Route::get('/notification', function () {
     $data = [
            array("username" => "raja", "email" => "raja@gmail.com"),
            array("username" => "admin", "email" => "admin@gmail.com")
        ];

    event(new StatusLiked($data));
    return "Notification has been sent!";
});