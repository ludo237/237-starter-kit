<?php

declare(strict_types=1);

use App\Providers\AppServiceProvider;
use App\Providers\FortifyServiceProvider;
use App\Providers\SanctumServiceProvider;

return [
    AppServiceProvider::class,
    SanctumServiceProvider::class,
    FortifyServiceProvider::class,
];
