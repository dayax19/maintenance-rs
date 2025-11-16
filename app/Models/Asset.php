<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
class Asset extends Model {
    use HasFactory;
    protected $fillable = ['asset_code','name','category_id','room_id','vendor_id','serial_number','acquisition_date','pm_interval_days','last_pm_date','calibration_interval_days','last_calibration_date','qr_code','manual_file'];
    public function category(){ return $this->belongsTo(Category::class); }
    public function room(){ return $this->belongsTo(Room::class); }
    public function vendor(){ return $this->belongsTo(Vendor::class); }
    public function pms(){ return $this->hasMany(MaintenancePM::class,'asset_id'); }
    public function cms(){ return $this->hasMany(MaintenanceCM::class,'asset_id'); }
}
