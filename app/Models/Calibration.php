<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
class Calibration extends Model {
    use HasFactory;
    protected $fillable=['asset_id','performed_by','calibration_date','expiry_date','certificate_file','notes'];
    public function asset(){ return $this->belongsTo(Asset::class); }
}
