<?php
namespace App\Http\Controllers\Api;
use App\Http\Controllers\Controller;
use App\Models\Asset;
use Illuminate\Http\Request;
class AssetApiController extends Controller {
    public function index(Request $r){
        $q = Asset::with(['category','room','vendor'])->orderBy('id','desc');
        if($r->has('q')) $q->where('name','like','%'.$r->q.'%');
        return response()->json($q->paginate(20));
    }
    public function show($id){
        $a = Asset::with(['category','room','vendor','pms','cms'])->findOrFail($id);
        return response()->json($a);
    }
    public function store(Request $r){
        $data = $r->validate([
            'asset_code'=>'required|unique:assets,asset_code',
            'name'=>'required'
        ]);
        $asset = Asset::create($data);
        return response()->json($asset,201);
    }
}
