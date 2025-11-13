<?php

declare(strict_types=1);

use Database\Factories\UserFactory;

uses(Illuminate\Foundation\Testing\RefreshDatabase::class);

test('guests are redirected to the login page', function (): void {
    $this->get(route('dashboard'))->assertRedirect(route('login'));
});

test('authenticated users can visit the dashboard', function (): void {
    $this->actingAs($user = UserFactory::new()->create());

    $this->get(route('dashboard'))->assertOk();
});
