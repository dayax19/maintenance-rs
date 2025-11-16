<?php
namespace App\Http\Controllers\Api;
use App\Http\Controllers\Controller;
use App\Models\MaintenanceCM;
use App\Models\MaintenancePM;
use Illuminate\Http\Request;
class WorkOrderApiController extends Controller {
    public function cms(Request $r){
        return response()->json(MaintenanceCM::with('asset','technician','reporter')->paginate(20));
    }
    public function createCm(Request $r){
        $data = $r->validate([
            'asset_id'=>'required',
            'description'=>'required',
            'priority'=>'required'
        ]);
        $data['ticket_code'] = 'CM-'.time();
        $data['reported_at'] = now();
        $cm = MaintenanceCM::create($data);
        return response()->json($cm,201);
    }
    public function completeCm(Request $r, $id){
        $cm = MaintenanceCM::findOrFail($id);
        $cm->status = 'resolved';
        $cm->resolved_at = now();
        $cm->save();
        return response()->json($cm);
    }
    public function pms(Request $r){
        return response()->json(MaintenancePM::with('asset','technician')->paginate(20));
    }
    public function createPm(Request $r){
        $data = $r->validate(['asset_id'=>'required','scheduled_date'=>'required']);
        $data['ticket_code'] = 'PM-'.time();
        $pm = MaintenancePM::create($data);
        return response()->json($pm,201);
    }
}
