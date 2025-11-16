<?php
namespace App\Http\Controllers\Api;
use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
class AuthController extends Controller {
    public function login(Request $r){
        $r->validate(['email'=>'required','password'=>'required']);
        $user = User::where('email',$r->email)->first();
        if(!$user || !Hash::check($r->password,$user->password)){
            return response()->json(['message'=>'Invalid credentials'],401);
        }
        $token = $user->createToken('api-token')->plainTextToken;
        return response()->json(['user'=>$user,'token'=>$token]);
    }
    public function logout(Request $r){
        $r->user()->currentAccessToken()->delete();
        return response()->json(['message'=>'Logged out']);
    }
}
