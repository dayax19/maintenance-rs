<?php
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\AssetApiController;
use App\Http\Controllers\Api\WorkOrderApiController;

Route::post('/login',[AuthController::class,'login']);
Route::middleware('auth:sanctum')->group(function(){
    Route::post('/logout',[AuthController::class,'logout']);
    Route::get('/assets',[AssetApiController::class,'index']);
    Route::get('/assets/{id}',[AssetApiController::class,'show']);
    Route::post('/assets',[AssetApiController::class,'store']);
    Route::get('/cms',[WorkOrderApiController::class,'cms']);
    Route::post('/cms',[WorkOrderApiController::class,'createCm']);
    Route::post('/cms/{id}/complete',[WorkOrderApiController::class,'completeCm']);
    Route::get('/pms',[WorkOrderApiController::class,'pms']);
    Route::post('/pms',[WorkOrderApiController::class,'createPm']);
});
