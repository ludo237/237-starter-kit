<?php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUlids;

class PersonalAccessToken extends \Laravel\Sanctum\PersonalAccessToken
{
    use HasUlids;
}
