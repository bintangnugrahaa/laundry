<?php

use App\Http\Controllers\api\LaundryController;
use App\Http\Controllers\api\PromoController;
use App\Http\Controllers\api\ShopController;
use App\Http\Controllers\api\UserController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/promo', [PromoController::class, 'readAll']);
Route::get('/shop', [ShopController::class, 'readAll']);
Route::get('/laundry', [LaundryController::class, 'readAll']);
Route::get('/user', [UserController::class, 'readAll']);

Route::post('/register', [UserController::class, 'register']);
Route::post('/login', [UserController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
  Route::get('/laundry/user/{id}', [LaundryController::class, 'whereUserId']);

  Route::get('/promo/limit', [PromoController::class, 'readLimit']);

  Route::get('/shop/recommendation/limit', [ShopController::class, 'readRecommendationLimit']);
  Route::get('/shop/search/city/{name}', [ShopController::class, 'searchByCity']);
});
