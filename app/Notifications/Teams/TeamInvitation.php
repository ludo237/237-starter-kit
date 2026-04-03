<?php

declare(strict_types=1);

namespace App\Notifications\Teams;

use App\Enums\TeamRole;
use App\Models\Team;
use App\Models\TeamInvitation as TeamInvitationModel;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class TeamInvitation extends Notification implements ShouldQueue
{
    use Queueable;

    /**
     * Create a new notification instance.
     */
    public function __construct(public TeamInvitationModel $invitation)
    {
        //
    }

    /**
     * Get the notification's delivery channels.
     *
     * @return array<int, string>
     */
    public function via(object $notifiable): array
    {
        return ['mail'];
    }

    /**
     * Get the mail representation of the notification.
     */
    public function toMail(object $notifiable): MailMessage
    {
        $team = $this->invitation->team;
        $inviter = $this->invitation->inviter;

        return (new MailMessage)
            ->subject("You've been invited to join ".$team->name)
            ->line(sprintf('%s has invited you to join the %s team.', $inviter->name, $team->name))
            ->action('Accept invitation', url(sprintf('/invitations/%s/accept', $this->invitation->code)));
    }

    /**
     * Get the array representation of the notification.
     *
     * @return array<string, mixed>
     */
    public function toArray(object $notifiable): array
    {
        /** @var Team $team */
        $team = $this->invitation->getRelation('team');
        /** @var TeamRole $role */
        $role = $this->invitation->getRelation('role');

        return [
            'invitation_id' => $this->invitation->getKey(),
            'team_id' => $this->invitation->getAttributeValue('team_id'),
            'team_name' => $team->getAttributeValue('name'),
            'role' => $role->value,
        ];
    }
}
